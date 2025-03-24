# require "test_helper"
# require "tor_blacklist"
#
# describe TorBlacklist do
#   let(:file_contents) do
#     <<LIST
# 192.168.1.1
# 192.168.1.2
# 192.168.1.3
# 192.168.1.4
# LIST
#   end
#
#   subject { TorBlacklist }
#
#   after(:each) do
#     subject.reset
#   end
#
#   describe ".ips" do
#     it "parses the IPs from a blacklist file" do
#       list_of_ips = file_contents.split
#       subject.expects(:read_blacklist_file).returns(list_of_ips)
#       subject.ips.must_equal %w( 192.168.1.1 192.168.1.2 192.168.1.3 192.168.1.4 )
#     end
#
#     it "does not open the file again once it is read" do
#       subject.expects(:read_blacklist_file).once.returns([])
#       subject.ips
#       subject.ips
#     end
#
#     it "re-parses the IPs from the blacklist file when it is updated" do
#       subject.expects(:read_blacklist_file).twice.returns([])
#       subject.ips
#       subject.stubs(:file_updated?).returns(true)
#       subject.ips
#     end
#   end
#
#   describe ".tor_ips?" do
#     it "returns true if the supplied IP is on the list" do
#       subject.stubs(:ips).returns(["192.168.1.1"])
#       subject.tor_ips?("192.168.1.1").should be_true
#     end
#
#     it "returns false if the IP is not included on the list" do
#       subject.stubs(:ips).returns(["192.168.1.1"])
#       subject.tor_ips?("192.168.1.2").should be_false
#     end
#   end
#
#   describe ".read_blacklist_file" do
#     before(:each) do
#       subject.stubs(:blacklist_file_path).returns(Pathname.new("./spec/fixtures/tor.db"))
#     end
#
#     it "reads the file" do
#       contents = subject.read_blacklist_file
#       contents.should be_an Array
#       contents.should have(4).lines
#     end
#   end
#
#   describe ".blacklist_file_path" do
#     it "defaults to db/tor.db" do
#       root = Pathname.new(".")
#       subject.blacklist_file_path(root).must_equal root.join("db/tor.db")
#     end
#   end
#
#   describe ".file_updated?" do
#     it "returns false if the file has not been read yet" do
#       subject.stubs(:current_mtime).returns(nil)
#       subject.file_updated?.should be_false
#     end
#
#     it "returns true if mtime of the file has changed" do
#       subject.stubs(:current_mtime).returns(Time.now)
#       subject.stubs(:new_mtime).returns(Time.now)
#       subject.file_updated?.should be_true
#     end
#
#     it "returns false the file has not changed" do
#       time = Time.now
#       subject.stubs(:current_mtime).returns(time)
#       subject.stubs(:new_mtime).returns(time)
#       subject.file_updated?.should be_false
#     end
#   end
# end

