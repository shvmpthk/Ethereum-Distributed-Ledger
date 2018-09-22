pragma solidity ^0.4.0;

contract BidData{
    
    struct Data{
        bytes32 id;
        address sensor;
        uint dataPoints;
        bytes32 dataHash;
        uint timestamp;
        bytes32 location;
        address farmManager;
        address bidder;
        uint bid;
        uint index;
        bool bidOpen;
    }
    
    mapping(bytes32=>Data) data;
    mapping(address=>bytes32[]) dataOwned;
    
    function addNewData(bytes32 data_id, address sensor_addr, uint dataPoints, bytes32 dataHash, uint timestamp, bytes32 location) public payable{
        if(data[data_id].sensor ==address(0) && data_id != 0)    // New data has arrived & data_id is not empty
        {
            data[data_id].id = data_id;
            data[data_id].sensor = sensor_addr;
            data[data_id].dataPoints = dataPoints;
            data[data_id].dataHash = dataHash;
            data[data_id].timestamp = timestamp;
            data[data_id].location = location;
            data[data_id].farmManager = msg.sender;
            data[data_id].bidder =msg.sender;
            data[data_id].bid = msg.value;
            data[data_id].bidOpen = true;

            data[data_id].index = dataOwned[msg.sender].push(data_id) - 1;
        }
    }
    
    function bid(bytes32 data_id) public payable{
        if(data[data_id].bidOpen) {
            address oldBidder = data[data_id].bidder;
            uint oldBid = data[data_id].bid;
            address newBidder = msg.sender;
            uint newBid = msg.value;
    
            if (oldBid < newBid) {
                if(oldBid != 0) {               //contract owes money to be given
                    oldBidder.transfer(oldBid);
                }
                data[data_id].bidder = newBidder;
                data[data_id].bid = newBid;
            }
            else{
                newBidder.transfer(newBid);     //give the sender money back cuz its of no use
            }
        }
    }
    
    function getHighestBid(bytes32 data_id) view public returns(uint) {
        return data[data_id].bid;
    }
    
    function closeBid(bytes32 data_id) public {
        if(msg.sender == data[data_id].farmManager) {   //msg.sender is the owner
            msg.sender.transfer(data[data_id].bid);     //Transfer the bidded money to the seller
            
            //transfer ownership of data to the highest bidder
            //delete dataOwned[data[data_id].farmManager][data[data_id].index];
            dataOwned[data[data_id].farmManager][data[data_id].index] = dataOwned[data[data_id].farmManager][dataOwned[data[data_id].farmManager].length-1];
            dataOwned[data[data_id].farmManager].length--;
            
            data[data_id].index = dataOwned[data[data_id].bidder].push(data_id) -1;
            data[data_id].bidOpen = false;
        }
    }
    
    function whoOwns(bytes32 data_id) view public returns (address){
        return data[data_id].bidder;
    }
    
    function countData(address addr) view public returns (uint){
        return dataOwned[addr].length;
    }
    
    function getDataDetails(address addr, uint index) view public returns (bytes32,address,bytes32,bytes32,uint,uint,address,address,bool){
        Data memory d = data[dataOwned[addr][index]];
        return (d.id, d.sensor, d.dataHash, d.location, d.bid, d.timestamp, d.farmManager,d.bidder,d.bidOpen);
    }
    
    function getDataDetailsById(bytes32 data_id) view public returns (bytes32,address,bytes32,bytes32,uint,uint,address,address,bool){
        Data memory d = data[data_id];
        return (d.id, d.sensor, d.dataHash, d.location, d.bid, d.timestamp, d.farmManager,d.bidder,d.bidOpen);
    }
}

