//=============================================================================
// ExplosiveFlakAmmoPickup.
//=============================================================================
class ExplosiveFlakAmmoPickup extends FlakAmmoPickup;

var int currentShell;
var int fired;
var Rotator shellRotation;

function TakeDamage(int damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
   instigator = eventInstigator;

   GotoState('Exploding');
}

state Exploding
{
   ignores Touch, TakeDamage;

   function BeginState()
   {
      NetUpdateTime = Level.TimeSeconds - 1;
      bHidden = true;
      bProjTarget = false;
   }

   function HurtEverything()
   {
      local float damage, radius, momentum;

      damage = ((AmmoAmount - fired) * class'FlakShell'.default.Damage) / 2;
      radius = class'FlakShell'.default.DamageRadius;
      momentum = class'FlakShell'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'DamTypeFlakShell', momentum, Location);
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'XEffects.FlakExplosionSnd', , 1.0, , 800);

      effect = Spawn(class'RocketExplosion');
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

Begin:
   fired = Rand(AmmoAmount / 2) + AmmoAmount / 2 + 1;

   // Then spawn a nice little explosion.
   SpawnExplosionEffect();

   // Next, hurt anything that's nearby.
   HurtEverything();

   // Sleep for a tick so that the hurt can go off before
   // the projectiles;
   Sleep(0.0);

   for (currentShell = 0; currentShell < fired; currentShell++)
   {
      shellRotation = Rotation;
      shellRotation.Pitch += Rand(16383);
      shellRotation.Yaw   =  Rand(65535);
      shellRotation.Roll  =  Rand(65535);

      if (FRand() > 0.7)
      {
         Spawn(class'FlakShell', instigator, , location, shellRotation).Speed = RandRange(0.2, 4.0);
      }
      else
      {
         Spawn(class'FlakChunk', instigator, , location, shellRotation).Speed = RandRange(0.2, 4.0);
      }
   }

   SetRespawn();
}

state Pickup
{
   function BeginState()
   {
      bProjTarget = true;
   }
}

state Sleeping
{
   ignores TakeDamage;
}
