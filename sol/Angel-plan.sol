
contract AngelPlan{

struct  Player {

    uint256 pID;       
    address payable addr;     
    uint256 affId;    
    uint256 totalBet;   

    uint256 curGen;     
    uint256 curAff;    
    address  inviteCode;
   
    uint256 lastBet;
    uint256 lastReleaseTime;
    
 
}


struct excellenceHistory{
   uint256 championId;
   uint256 champion;
   
   uint256 bronzeId;
   uint256 bronze;
}

uint256 ethWei = 1 ether;
uint256 firstMaxBet = 3 * ethWei;
uint256 maxBet = 6 * ethWei;

 uint256  private minbeteth_ = ethWei;          
 uint256 constant private getoutBeishu = 31;                
 uint256 public nextId_ = 1;                            
 uint256  genReleTime_ = 1 days;             
 bool public activated_ = true;     
 mapping (string   => uint256) public pIDInviteCode_;
 
 mapping (uint256 => playerPot) public playerPot_;


 uint256[21] affRate = [300,200,100,50,50,50,50,50,50,50,20,20,20,20,20,20,20,20,20,20,20];
 
 

modifier isActivated() {
    require(activated_ == true, "its not ready yet.  check ?eta in discord");
    _;
}



constructor()
public
{
    
    insuranceStartTime_ = now;
    excellenceStartTime_ = now;
}


function determinePID()
    private
{
    
    uint256 _pID = pIDxAddr_[msg.sender];
  
    if (_pID == 0)
    {
       
        _pID = nextId_;
        plyr_[_pID].pID =_pID;  
        nextId_++;
        plyr_[_pID].addr  = msg.sender;
        pIDxAddr_[msg.sender] = _pID;
        
        
    }
    
}

function checkAffid(uint256 _pID,uint256 _affID)
private
returns(bool)
{
    
     _affID = plyr_[_affID].affId;
     if(_affID == 0)
    {
        return true;
    }
    
     if(_affID == _pID)
    {
        return false;
    }
    
    return checkAffid(_pID,_affID);
}


 function ethcomein(address _affAddr)
        isActivated()
        isHuman()
        public
        payable
    {
        
        determinePID();
        
     
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _affID = address(0) ==_affAddr?0:pIDxAddr_[_affAddr];
       
        if(_affID != 0 && _affID != _pID  && plyr_[_pID].affId ==0 && checkAffid(_pID,_affID))
        {
            plyr_[_pID].affId = _affID;
            plyr_[_pID].affTime = now;
            plyr_[_affID].invites = plyr_[_affID].invites + 1 ;
           
        }
    
      
        buyCore(_pID,msg.value);
    }




function buyCore(uint256 _pID,uint256 _eth)
    isOut()
    isWithinLimits(msg.value)
    private
{
    
   
   
    uint256 _maintenance = _eth.mul(3)/100;
    if(_maintenance>0){
        maintenance.transfer(_maintenance);
    }
        

  
    uint256 _inPool = _eth.mul(1)/100;
    if(_inPool>0){
        
         if(now > insuranceStartTime_.add(insuranceTime_)){
            openInsurancer = msg.sender;
            inPoolCoin = 0;
        }
        
        insuranceStartTime_ = now;
        bx.transfer(_inPool);
        inPoolCoin = inPoolCoin.add(_inPool);
    }
    
    
  
    gBet_ = gBet_.add(_eth);
    gBetcc_= gBetcc_ + 1; 
    
  
    dealwithExcellencePot(_eth);
    if(plyr_[_pID].affId > 0){
        
        drUserBet_[excellenceRound_][plyr_[_pID].affId] = drUserBet_[excellenceRound_][plyr_[_pID].affId].add(_eth);
        statisticalDirBet(plyr_[_pID].affId);
    }
    
    plyr_[_pID].totalBet = _eth.add(plyr_[_pID].totalBet);
    plyr_[_pID].lastBet  = _eth;
    plyrReward_[_pID].reward = (_eth.mul(getoutBeishu)/10).add(plyrReward_[_pID].reward);

    

   
    uint256 _curBaseGen = _eth.mul(1) /100;
    plyr_[_pID].baseGen = plyr_[_pID].baseGen.add(_curBaseGen);

  
    plyr_[_pID].lastReleaseTime = now;
  
}






//algebra
function getAlg (uint256 _pID) 
public
view
returns(uint256 _al) 
{
    _al = 0;
    
    if(plyr_[_pID].invites>= 15){
        _al = 21;
        
    }else if(plyr_[_pID].invites>= 14){
        _al = 14;
        
    }else {
        _al = plyr_[_pID].invites;
        
    }
}



function rrHistory(uint256 _pid,uint256 _eth,uint8 _type)
private{
    
    rrHistory_[rrId_].pid =_pid;
    rrHistory_[rrId_].addr = plyr_[_pid].addr;
    rrHistory_[rrId_].eth = _eth;
    rrHistory_[rrId_].rrTime = now;
    rrHistory_[rrId_].rrtype = _type;
    rrId_++;
}   



function getPlayerlaByAddr (address _addr)
public
view
returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)
{
    uint256 _pID = pIDxAddr_[_addr];
    
    
    
    uint256 totalGenH =  plyrReward_[_pID].totalGen - plyrReward_[_pID].withDrawEdGen;
    uint256 totalAffH =  plyrReward_[_pID].totalAff - plyrReward_[_pID].withDrawEdAff;
    
    return(
        _pID,
        plyrReward_[_pID].reward.sub(plyr_[_pID].curGen + plyr_[_pID].curAff)>0?plyrReward_[_pID].reward.sub(plyr_[_pID].curGen + plyr_[_pID].curAff):0,
        plyrReward_[_pID].totalGen,
        plyrReward_[_pID].totalAff,
        totalGenH,
        totalAffH,
   
        plyr_[_pID].baseGen,
        plyr_[_pID].baseAff,
        drUserBet_[excellenceRound_][_pID]
        
        );


}


function getPlayerlaById (uint256 _pID)
public
view
returns(uint256 affid,address addr,uint256 totalBet,uint256 level,uint256 withDrawEdGen,uint256 withDrawEdAff,address affInviteAddr,uint256 affTime,uint256 excellencepot)
{
   require(_pID>0 && _pID < nextId_, "Now cannot withDraw!");
   
    affid =  plyr_[_pID].affId;
    addr  = plyr_[_pID].addr;
    totalBet = plyr_[_pID].totalBet;
    level = plyrReward_[_pID].level;
    withDrawEdGen = plyrReward_[_pID].withDrawEdGen;
    withDrawEdAff = plyrReward_[_pID].withDrawEdAff;
  
    affInviteAddr =plyr_[plyr_[_pID].affId].addr;
    affTime = plyr_[_pID].affTime;
    excellencepot = playerPot_[_pID].excellencepot;
      


}


function somethingmsg () 
public
view
returns(uint256 _minbeteth,uint256 _genReleTime)
{
    return(
    
        minbeteth_,
        genReleTime_
        );

}



function getExHistory(uint256 _rid)
public
view
returns(uint256 _championId,uint256 _champion,uint256 _firInviteEth,address _championAddr,uint256 _bronzeId,uint256 _bronze,uint256 _secInviteEth,address _bronzeAddr){
    
    _championId = exHistory_[_rid].championId;
    _champion = exHistory_[_rid].champion;
    _firInviteEth = drUserBet_[_rid][_championId];
    _championAddr = plyr_[_championId].addr;
    
    _bronzeId = exHistory_[_rid].bronzeId;
    _bronze = exHistory_[_rid].bronze;
    _secInviteEth = drUserBet_[_rid][_bronzeId];
    _bronzeAddr = plyr_[_bronzeId].addr;
    
    
    
}

function getsystemMsg()
public
view
returns(uint256 _gbet,uint256 _gcc,uint256 _zypot,uint256 _zytime,uint256 _bxTotalCoin,uint256 _zyround,uint256 _bxTime)
{
    return
    (
        gBet_,
        gBetcc_,
        excellencePot_,
        excellenceTime_+excellenceStartTime_,
        inPoolCoin,
        excellenceRound_,
        insuranceStartTime_ + insuranceTime_
        
        
    );
}