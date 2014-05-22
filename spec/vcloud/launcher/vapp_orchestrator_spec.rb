require 'spec_helper'

describe Vcloud::Launcher::VappOrchestrator do
  # Testing class methods rather than instance methods.
  let(:subject) { Vcloud::Launcher::VappOrchestrator }

  context "provision a vapp" do

    let(:mock_fog_vm) {
      double(:vm)
    }
    let(:mock_vapp) {
      double(:vapp, :fog_vms => [mock_fog_vm], :reload => self)
    }
    let(:mock_vm_orchestrator) {
      double(:vm_orchestrator, :customize => true)
    }

    before(:each) do
      @config = {
          :name => 'test-vapp-1',
          :vdc_name => 'test-vdc-1',
          :catalog => 'org-1-catalog',
          :catalog_item => 'org-1-template',
          :vm => {
              :network_connections => [{:name => 'org-vdc-1-net-1'}]
          }
      }
    end

    it "should return a vapp if it already exists" do
      existing_vapp = double(:vapp, :name => 'existing-vapp-1')

      Vcloud::Core::Vapp.should_receive(:get_by_name_and_vdc_name).with('test-vapp-1', 'test-vdc-1').and_return(existing_vapp)
      Vcloud::Core.logger.should_receive(:info).with('Found existing vApp test-vapp-1 in vDC \'test-vdc-1\'. Skipping.')
      actual_vapp = subject.provision @config
      actual_vapp.should_not be_nil
      actual_vapp.should == existing_vapp
    end

    it "should create a vapp if it does not exist" do
      #this test highlights the problems in vapp

      Vcloud::Core::Vapp.should_receive(:get_by_name_and_vdc_name).with('test-vapp-1', 'test-vdc-1').and_return(nil)
      Vcloud::Core::VappTemplate.should_receive(:get).with('org-1-template', 'org-1-catalog').and_return(double(:vapp_template, :id => 1))

      Vcloud::Core::Vapp.should_receive(:instantiate).with('test-vapp-1', ['org-vdc-1-net-1'], 1, 'test-vdc-1')
      .and_return(mock_vapp)
      Vcloud::Launcher::VmOrchestrator.should_receive(:new).with(mock_fog_vm, mock_vapp).and_return(mock_vm_orchestrator)

      new_vapp = subject.provision @config
      new_vapp.should == mock_vapp
    end

  end
end
