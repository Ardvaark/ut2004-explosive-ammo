//=============================================================================
// TimedONSGrenadeProjectile.
//=============================================================================
class TimedONSGrenadeProjectile extends ONSGrenadeProjectile;

var bool timerSet;

simulated function PostNetBeginPlay()
{
   super.PostNetBeginPlay();
   
   if (self.Physics == PHYS_None)
   {
      self.SetTimer(class'Grenade'.default.ExplodeTimer, false);
      timerSet = true;
   }
}

simulated function HitWall(Vector hitNormal, Actor wall)
{
   if (!timerSet)
   {
      self.SetTimer(class'Grenade'.default.ExplodeTimer, false);
      timerSet = true;
   }
   
   super.HitWall(hitNormal, wall);
}

simulated function Timer()
{
   self.Explode(self.Location, Vect(0, 0, 1));
}
