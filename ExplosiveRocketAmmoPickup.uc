//=============================================================================
// ExplosiveRocketAmmoPickup.
//=============================================================================
class ExplosiveRocketAmmoPickup extends RocketAmmoPickup;

var int        currentShell;
var int        fired;
var Rotator    shellRotation;
var Projectile currentProjectile;

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

      damage = ((AmmoAmount - fired) * class'RocketProj'.default.Damage) / 2;
      radius = class'RocketProj'.default.DamageRadius;
      momentum = class'RocketProj'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'DamTypeRocket', momentum, Location);
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - fired) * TransientSoundVolume);

      effect = Spawn(class'RocketExplosion', instigator);
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

Begin:
	fired = Rand(AmmoAmount / 2);

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
      shellRotation.Pitch += Rand(32767);
      shellRotation.Yaw   =  Rand(65535);
      shellRotation.Roll  =  Rand(65535);

      currentProjectile = Spawn(class'RocketProj', instigator, , location, shellRotation);
      currentProjectile.Velocity = Vector(shellRotation) * class'RocketProj'.default.Speed * RandRange(0.2, 2.0);

      if (currentShell % 5 == 0)
      {
         Sleep(FRand() * 0.02);
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

defaultproperties
{
}
