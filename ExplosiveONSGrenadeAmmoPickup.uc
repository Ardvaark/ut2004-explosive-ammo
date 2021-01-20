//=============================================================================
// ExplosiveONSGrenadeAmmoPickup.
//=============================================================================
class ExplosiveONSGrenadeAmmoPickup extends ONSGrenadeAmmoPickup;

var int        currentShell;
var int        fired;
var Rotator    shellRotation;
var Projectile currentProjectile;

function TakeDamage(int damage, Pawn eventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
   self.Instigator = eventInstigator;

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

      damage = ((AmmoAmount - fired) * class'ONSGrenadeProjectile'.default.Damage) / 2;
      radius = class'ONSGrenadeProjectile'.default.DamageRadius;
      momentum = class'ONSGrenadeProjectile'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'DamTypeONSGrenade', momentum, Location);
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - fired) * TransientSoundVolume);

      effect = Spawn(class'RocketExplosion', instigator);
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
   Sleep(0.01);

   Log("Firing " $ fired $ " grenades.");

   for (currentShell = 0; currentShell < fired; currentShell++)
   {
      shellRotation = RotRand();

      currentProjectile = Spawn(class'TimedONSGrenadeProjectile', instigator, , location, shellRotation);
      currentProjectile.Velocity = Vector(shellRotation) * class'ONSGrenadeProjectile'.default.Speed * RandRange(0.5, 0.8);

      Sleep(FRand() * 0.02);
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

