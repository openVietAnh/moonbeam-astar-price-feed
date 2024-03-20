pragma solidity >=0.8.2 <0.9.0;

contract Storage {

    int256 number;

    function store(int256 num) public {
        number = num;
    }

    function retrieve() public view returns (int256) {
        return number;
    }
}