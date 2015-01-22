require 'spec_helper'

describe ProxyService do

  subject { described_class.new(:trip_advisor) }

  describe '#new_worker' do
    context 'when proxies are enabled' do
      before { subject.proxies_enabled = true }

      it 'returns a new ProxyWorker' do
        worker = subject.new_worker
        expect(worker).to be_a(ProxyService::Worker)
        expect(worker.queue).to eq 'proxy/trip_advisor'
      end
    end

    context 'when proxies are disabled' do
      it 'returns a new NullWorker' do
        expect(subject.new_worker).to be_a(ProxyService::NullWorker)
      end
    end
  end

  describe '#with_mechanize' do
    let(:worker) { ProxyService::NullWorker.new }
    let(:proxy) { ProxyService::Proxy.new(worker) }

    before(:each) { allow(subject).to receive(:reserve_proxy).and_return(proxy) }

    it 'passes a new mechanize agent to the given block' do
      expect_any_instance_of(ProxyService::MechanizeAgent).to receive(:set_proxy).with(proxy)
      subject.with_mechanize do |agent|
        expect(agent).to be_a(ProxyService::MechanizeAgent)
        expect(agent).to respond_to(:get)
      end
    end

    it 'releases the proxy and resets its failures count' do
      expect(proxy).to receive(:reset_failures)
      expect(proxy).to receive(:release)
      subject.with_mechanize { |_| }
    end

    context 'when there is an exception' do
      let(:mechanize_error) { Mechanize::ResponseCodeError.new(OpenStruct.new(code: '403')) }

      it 'does not reset the failures count' do
        expect(proxy).to_not receive(:reset_failures)
        expect(proxy).to receive(:release)
        subject.with_mechanize { |_| raise mechanize_error }
      end

      context 'when +failures+ exceeds max failures' do
        it 'blocks the proxy' do
          expect(proxy).to receive(:failures).and_return(subject.failure_limit + 1)
          expect(proxy).to receive(:blocked!)
          subject.with_mechanize { |_| raise mechanize_error }
        end
      end

      context 'when +failures+ does not exceed max failures' do
        it "increments the proxy's +failures+ count" do
          expect(proxy).to receive(:increment_failures)
          subject.with_mechanize { |_| raise mechanize_error }
        end
      end
    end
  end
end
