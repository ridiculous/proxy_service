require 'spec_helper'

describe ProxyService::MechanizeAgent, slow: true do

  describe '#set_proxy' do
    context 'when -proxy- has an +ip+' do
      let(:proxy) { double('Proxy', ip: '127.0.0.1', port: 8080) }

      it 'calls +set_proxy+ on the underlying object' do
        expect(subject.__getobj__).to receive(:set_proxy).with(proxy.ip, proxy.port, nil, nil)
        subject.set_proxy(proxy)
      end
    end

    context 'when -proxy- does not have an +ip+' do
      let(:proxy) { double('Proxy', ip: nil) }

      it 'does not call +set_proxy+ on the underlying object' do
        expect(subject.__getobj__).to_not receive(:set_proxy)
        subject.set_proxy(proxy)
      end
    end
  end

end
