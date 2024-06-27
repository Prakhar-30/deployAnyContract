//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract TestContract1{
    address public owner=msg.sender;
    function setOwner(address _owner) public {
        require(msg.sender==owner,"not the owner");
        owner=_owner;
    }
}
contract TestContract2{
    address public owner=msg.sender;
    uint public value=msg.value;
    uint public x;
    uint public y;
    constructor(uint _x,uint _y) payable {
        x=_x;
        y=_y;
    }

}

contract Helper{ 
    function getByteCode1() external pure returns(bytes memory bytecode){
        bytecode=type(TestContract1).creationCode;
    }
    function getByteCode2(uint _x, uint _y) external pure returns(bytes memory){
        bytes memory bytecode=type(TestContract2).creationCode;
        return abi.encodePacked(bytecode,abi.encode(_x,_y));
    }
    function getCalldata(address _owner) external pure returns(bytes memory){
        return abi.encodeWithSignature("setOwner(address)", _owner);
    }
}

contract Proxy {
    event Deploy(address addr);

    // Receives function to accept ETH without data
    receive() external payable { }

    // Fallback function to accept ETH with data
    fallback() external payable { }

    // Function to deploy a new contract
    function deploy(bytes memory _code) external payable returns (address addr) {
        assembly {
            addr := create(callvalue(), add(_code, 0x20), mload(_code))
        }
        require(addr != address(0), "deploy failed");
        emit Deploy(addr);
    }

    // Function to execute calls on the deployed contract
    function execute(address _target, bytes memory _data) external payable {
        (bool success, ) = _target.call{value: msg.value}(_data);
        require(success, "execute failed");
    }
}
