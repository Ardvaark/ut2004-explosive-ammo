//=============================================================================
// ExplosiveONSMineAmmoPickup.
//=============================================================================
class ExplosiveONSMineAmmoPickup extends ONSMineAmmoPickup;

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

      damage = ((AmmoAmount - fired) * class'ONSMineProjectile'.default.Damage) / 2;
      radius = class'ONSMineProjectile'.default.DamageRadius;
      momentum = class'ONSMineProjectile'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'DamTypeONSMine', momentum, Location);
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - fired) * TransientSoundVolume);

      effect = Spawn(class'RocketExplosion', instigator);
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

Begin:
   fired = Rand(AmmoAmount / 3) + AmmoAmount / 3 + 1;

   // Then spawn a nice little explosion.
   SpawnExplosionEffect();

   // Next, hurt anything that's nearby.
   HurtEverything();

   // Sleep for a tick so that the hurt can go off before
   // the projectiles;
   Sleep(0.01);

   for (currentShell = 0; currentShell < fired; currentShell++)
   {
      shellRotation = RotRand();

      currentProjectile = Spawn(class'TimedONSMineProjectile', instigator, , location, shellRotation);
      currentProjectile.Velocity = Vector(shellRotation) * class'ONSMineProjectile'.default.Speed * RandRange(0.5, 0.8);

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
