//=============================================================================
// ExplosiveBioAmmoPickup.
//=============================================================================
class ExplosiveBioAmmoPickup extends BioAmmoPickup;

function TakeDamage(int damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
   local int i;
   local Projectile projectile;

   SetRespawn();
   bProjTarget = false;

   for (i = 0; i < AmmoAmount; i++)
   {
      projectile = Spawn(class'BioGlob', instigator, , , RotRand());

      if (projectile != none)
      {
         projectile.Speed = RandRange(1.0, 800.0);
      }
      else
      {
         Warn("Unable to create projectile!");
      }
   }
}

state Pickup
{
   function BeginState()
   {
      bProjTarget = true;

      super.BeginState();
   }
}

state Sleeping
{
   ignores TakeDamage;
}

defaultproperties
{
}

