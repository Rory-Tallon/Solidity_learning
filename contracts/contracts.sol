pragma solidity >=0.4.22 < 0.8.20;

contract main {

    p2p p2p_contract;

    constructor (p2p peer2peer) {
        p2p_contract = peer2peer;
    }

    function registerProsumer() public noProsumerExists {
        // msg.sender
        p2p_contract.addNewProsumer(msg.sender);
    }

    function deposit() public prosumerExists(msg.sender) payable{
        // msg.value is the deposit value
        // modifier checks that the user actually exists
        p2p_contract.setEtherBalance(msg.value/1e18, msg.sender);    
    }

    
    function withdraw() public prosumerExists(msg.sender)  hasPositiveEnergyBalance(msg.sender) payable{
        // users can only withdraw if they have an energy balance >= 0
        if(checkEnergyStatus()>=0){
            // withdraw
            payable(msg.sender).transfer(p2p_contract.getEtherBalance(msg.sender)*1e18);
        }
            
    }
    function checkEtherStatus() public view prosumerExists(msg.sender) returns (uint){
        // msg.value is the deposit value
        // modifier checks that the user actually existss
        return p2p_contract.getEtherBalance(msg.sender);
    }

    function checkEnergyStatus() public view prosumerExists(msg.sender) returns (int){
        // modifier checks that the user actually existss
        return p2p_contract.getEnergyBalance(msg.sender);
    }

    function buyEnergy(int energy) public prosumerExists(msg.sender) buyerHasEnoughEthers(uint(energy),msg.sender) {
        p2p_contract.buyEnergy(energy, msg.sender);
    }

    function sellEnergy(int energy) public prosumerExists(msg.sender) sellerHasEnoughEnergy(energy, msg.sender){
        p2p_contract.sellEnergy(energy, msg.sender);
    }

    function energyRequest(int energy) public prosumerExists(msg.sender)  {
        
        if (energy > 0){
            //if someone has positive energy balance they wanna sell
            sellEnergy(energy);
        } else {
            //if someone has negative energy balance they wanna buy
            buyEnergy(energy);
        }
    }

    function setEnergyStatus(int energy) public prosumerExists(msg.sender) {
        p2p_contract.setEnergyBalance(energy, msg.sender);
    }

    // function getEnergyStatus() public prosumerExists {
    //     p2p_contract.getEnergyBalance();
    // }

    modifier prosumerExists(address id) {
        require(p2p_contract.getId(msg.sender) != address(0), "This prosumer does not exist.");
        _;
    }

    modifier noProsumerExists() {
        require(p2p_contract.getId(msg.sender) == address(0), "This prosumer already exists.");
        _;
    }

    modifier buyerHasEnoughEthers(uint ethers, address id) {

        require(p2p_contract.getEtherBalance(id) >= ethers,"This buyer does not have enough ethers.");
        _;
    }

    modifier sellerHasEnoughEnergy(int energy, address id){
        require(p2p_contract.getEnergyBalance(id)>=energy, "This seller is trying to sell energy it does not have.");
        _;
    }
    
    modifier hasPositiveEnergyBalance(address id){
        require(p2p_contract.getEnergyBalance(id)>=0, "This buyer has a negative energy balance and cannot withdraw.");
        _;
    }


}


contract p2p {
    struct Prosumer {
        address id;
        int energyBalance;
        uint etherBalance;
    }

    mapping (address=>Prosumer) prosumers;
    address[] listOfProsumers;

    function addNewProsumer(address id) public {
        // prosumer = Prosumer(msg.sender,0,0);
        prosumers[id] = Prosumer(id,0,0);
        listOfProsumers.push(id);
    }

    function buyEnergy(int energy, address id) public {
        // iterate over listOfProsumers
        // find someone that has positive energy balance and transfer
        for (uint i = 0; i<listOfProsumers.length; i++){
            //they are a seller
            if(prosumers[listOfProsumers[i]].energyBalance>0){
                    // if prosumer we are on has enough energy to sell to cover our transaction do it all
                if (prosumers[listOfProsumers[i]].energyBalance>=energy){

                    // increase our energy balance
                    prosumers[id].energyBalance += energy;

                    // decrease their energy balance
                    prosumers[listOfProsumers[i]].energyBalance -= energy;

                    // increase their ether balance
                    prosumers[id].etherBalance += uint(energy);

                    // decrease our ether balance
                    prosumers[listOfProsumers[i]].etherBalance -= uint(energy);

                    break;
                    //break loop as no more buying needs to occur

                //if prosumer can sell less energy than we need but can sell some
                } else if (energy>prosumers[listOfProsumers[i]].energyBalance){

                    // update how much energy we still want to buy
                    energy -= prosumers[listOfProsumers[i]].energyBalance;

                    // increase our energy balance by their energy balance
                    prosumers[id].energyBalance += prosumers[listOfProsumers[i]].energyBalance;

                    // decrease our ether balance by how much we bought
                    prosumers[id].etherBalance -= uint(prosumers[listOfProsumers[i]].energyBalance);

                    // increase their ether balance to how much they sold
                    prosumers[listOfProsumers[i]].etherBalance += uint(prosumers[listOfProsumers[i]].energyBalance);

                    // decrease their energy balance to zero
                    prosumers[listOfProsumers[i]].energyBalance = 0;

                }
            }

            

        }
    }

    function sellEnergy(int energy, address id) public {

        //check that we can sell this much energy
        for (uint i = 0; i<listOfProsumers.length; i++){
            if (prosumers[listOfProsumers[i]].energyBalance<0 ){

                int amountTheyCanBuy = prosumers[listOfProsumers[i]].energyBalance;


                // they want to buy all the energy we are selling
                // if the prosumers energy balance is enough 
                if(amountTheyCanBuy>=energy){
                    
                    // increase their energy balance
                    // decrease their ether balance
                    // increase our ether balance
                    // decrease our energy balance

                    prosumers[listOfProsumers[i]].energyBalance+=energy;
                    prosumers[listOfProsumers[i]].etherBalance-=uint(energy);
                    
                    prosumers[id].energyBalance -= energy;
                    prosumers[id].etherBalance += uint(energy);


                } else if (amountTheyCanBuy<energy ){
                    
                    //amount we are still looking to sell goes down by amountTheyCanBuy
                    energy-=amountTheyCanBuy;
                    //amount of energy we have goes down by amountTheyCanBuy
                    prosumers[id].energyBalance -= amountTheyCanBuy;

                    //our ether balance goes up by how much we sold
                    prosumers[id].etherBalance += uint(amountTheyCanBuy);

                    // their ether balance goes down by how much they bought
                    prosumers[listOfProsumers[i]].etherBalance-=uint(amountTheyCanBuy);

                    // their energy balance goes up by how much they bought
                    prosumers[listOfProsumers[i]].energyBalance+=amountTheyCanBuy;
                }
            }
        }
    }

    function getEnergyBalance(address id) public view returns (int) {
        return prosumers[id].energyBalance;
    }

    function setEnergyBalance(int energy, address id) public {
        prosumers[id].energyBalance=energy;
    }

    function getEtherBalance(address id) public view returns (uint) {
        return prosumers[id].etherBalance;
    }

    function getId(address id) public view returns (address) {
        return prosumers[id].id;
    }

    function setEtherBalance(uint ethers, address id) public {
        prosumers[id].etherBalance=ethers;
    }

}
