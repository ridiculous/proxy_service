require 'spec_helper'

describe ProxyService::Proxy do
  subject { described_class.new(ProxyService::NullWorker.new) }

  describe '#message' do
    context 'when message.body is present' do
      let(:message_body) { { ip: '127.0.0.1', port: '8080', failures: 1 }.to_json }

      it 'returns the contents as a hash' do
        expect(subject.worker.message).to receive(:body).and_return(message_body)
        expect(subject.message).to eq(JSON.parse(message_body))
      end
    end

    context 'when message.body is empty' do
      it "returns a hash with a 'failures' key set to 0" do
        expect(subject.message).to eq({ 'failures' => 0 })
      end
    end
  end

  describe '#release' do
    it 'passes itself to worker.release with the @blocked status' do
      expect(subject.worker).to receive(:release).with(subject, false)
      subject.release
    end
  end

  describe '#increment_failures' do
    it 'increments the @failures count by 1' do
      expect { subject.increment_failures }.to change(subject, :failures).from(0).to(1)
    end
  end

  describe '#reset_failures' do
    before { subject.failures = 2 }

    it 'resets the @failures count to 0' do
      expect { subject.reset_failures }.to change(subject, :failures).from(2).to(0)
    end
  end

  describe '#blocked!' do
    it 'sets @blocked to true' do
      expect { subject.blocked! }.to change(subject, :blocked?).from(false).to(true)
    end
  end
end
