// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./Owner.sol";

contract Main is Owner {
    
    enum propertyType { terrain, appartment, house }

    function getPropertyType(uint index) public pure returns (propertyType) {
        if(index == 0) return propertyType.terrain;
        if(index == 1) return propertyType.appartment;
        if(index == 2) return propertyType.house;
        revert();
    }

    struct propertyOwner {
        uint propertiesCount;
        uint balance;
        mapping(uint => property) properties;
    }

    struct property {
        uint id;
        string propertyAddress;
        uint propertySize;
        propertyType propertyType;
        uint value;
    }

    uint totalBalance;
    uint totalPropertiesCount;
    mapping(address => propertyOwner) propertyOwners;


    function addPropertyTo(address _newOwner, property memory _property) internal isOwner {
        propertyOwners[_newOwner].properties[propertyOwners[_newOwner].propertiesCount] = _property;
        propertyOwners[_newOwner].propertiesCount += 1;
        totalPropertiesCount++;
    }
    function removePropertyTo(address _newOwner, uint _propertyId) internal isOwner {
        bool find = false;
        for (uint i = _propertyId; i < propertyOwners[_newOwner].propertiesCount - 1; i++){
            if(propertyOwners[_newOwner].properties[i].id == _propertyId){
                find = true;
            }
            if(find == true){
                propertyOwners[_newOwner].properties[i] = propertyOwners[_newOwner].properties[i + 1];
            }
        }
        require(find, "Id doesn't exist in array.");
        delete propertyOwners[_newOwner].properties[propertyOwners[_newOwner].propertiesCount - 1];
        propertyOwners[_newOwner].propertiesCount--;
    }
    function changePropertyOwner(address _lastOwner, address _newOwner, uint _propertyId) internal {
        property memory _property = getPropertyFrom(_lastOwner, _propertyId);
        removePropertyTo(_lastOwner, _property.id);
        _property.id = propertyOwners[_newOwner].propertiesCount;
        addPropertyTo(_newOwner, _property);
    }


    function getTotalBalance() public view returns(uint){
        return totalBalance;
    }
    function getTotalProperties() public view returns(uint){
        return totalPropertiesCount;
    }
    function getMyProperties() public view returns(property[] memory){
        return getMyPropertiesFrom(msg.sender);
    }
    function getMyPropertiesFrom(address _owner) public view returns(property[] memory){
        property[] memory toReturn = new property[](propertyOwners[_owner].propertiesCount);
        for (uint i = 0; i < propertyOwners[_owner].propertiesCount; i++){
            toReturn[i] = propertyOwners[_owner].properties[i];
        }
        return toReturn;
    }
    function getPropertyFrom(address _owner, uint _propertyId) public view returns(property memory){
        for (uint i = _propertyId; i < propertyOwners[_owner].propertiesCount - 1; i++){
            if(propertyOwners[_owner].properties[i].id == _propertyId){
                return propertyOwners[_owner].properties[i];
            }
        }
        revert("Id doesn't exist in array.");
    }

    function depositBalance() external payable nonReentrant{
        propertyOwners[msg.sender].balance += msg.value;
        totalBalance += msg.value;
    }
    function withdrawBalance(uint amount) external payable nonReentrant{
        require(amount > propertyOwners[msg.sender].balance, "Not enought amount on your wallet");
        propertyOwners[msg.sender].balance -= msg.value;
        payable(msg.sender).transfer(msg.value);
    }
    function addProperty(address _newOwner, string memory _propertyAddress, uint _propertySize, propertyType _propertyType) public isOwner nonReentrant{
        addPropertyTo(_newOwner, property(totalPropertiesCount, _propertyAddress, _propertySize, _propertyType, 0));
    }
    function setPropertyToSell(uint _propertyId, uint _value) external nonReentrant{
        getPropertyFrom(msg.sender, _propertyId).value = _value;
    }
    function removePropertyToSell(uint _propertyId) external nonReentrant{
        getPropertyFrom(msg.sender, _propertyId).value = 0;
    }
    function buyProperty(address _lastOwner, uint _propertyId) external nonReentrant{
        uint _value = getPropertyFrom(_lastOwner, _propertyId).value;
        require(_value > propertyOwners[msg.sender].balance, "Not enought amount on your wallet.");
        changePropertyOwner(_lastOwner, msg.sender, _propertyId);
        propertyOwners[msg.sender].balance -= _value;
    }

}