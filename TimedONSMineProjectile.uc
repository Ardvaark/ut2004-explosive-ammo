//=============================================================================
// TimedONSMineProjectile.
//=============================================================================
class TimedONSMineProjectile extends ONSMineProjectile;

var float deathTime;
var bool  deathTimeSet;

simulated state OnGround
{
   simulated function BeginState()
   {
      if (!self.deathTimeSet)
      {
         self.deathTime = self.Level.TimeSeconds + RandRange(1.0, 7.0);
         self.deathTimeSet = true;
      }
      
      super.BeginState();
   }
   
   simulated function Timer()
   {
      if (self.Level.TimeSeconds >= self.deathTime)
      {
         self.BlowUp(self.Location);
      }
      else
      {
         super.Timer();
      }
   }
}

defaultproperties
{
   deathTimeSet = false;
}
