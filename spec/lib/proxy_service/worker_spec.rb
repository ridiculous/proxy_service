require 'spec_helper'

describe ProxyService::Worker do

  let(:queue_name) { 'proxy/trip_advisor' }
  let(:message) { {} }
  let(:proxy) { double('Proxy') }

  subject { described_class.new(queue_name) }

  describe '#call' do
    it 'sets @message to message and @ready to true' do
      expect(subject).to_not be_ready
      expect { subject.call(message) }.to change(subject, :message).from(nil).to(message)
      expect(subject).to be_ready
    end
  end

  describe '#release' do
    before(:each) { subject.message = message }

    it 'pops and then pushes the -proxy- onto the queue' do
      expect(subject).to receive(:ack).with(message)
      expect(subject).to receive(:unsubscribe)
      expect(subject).to receive(:publish).with(proxy)
      expect(subject).to receive(:close)
      subject.release(proxy, false)
    end

    context 'when proxy is blocked' do
      it 'pops the message from the queue but does not push it back on' do
        expect(subject).to receive(:ack).with(message)
        expect(subject).to receive(:unsubscribe)
        expect(subject).to_not receive(:publish).with(proxy)
        expect(subject).to receive(:close)
        subject.release(proxy, true)
      end
    end
  end
end
