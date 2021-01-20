//=============================================================================
// ExplosiveSniperAmmoPickup.
//=============================================================================
class ExplosiveSniperAmmoPickup extends SniperAmmoPickup
   placeable;

var int        currentBullet;
var int        fired;

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
      local float damage, radius, momentum, averageDamage;
      local int notFired;

      averageDamage = (class'XWeapons.SniperFire'.default.DamageMax + class'XWeapons.SniperFire'.default.DamageMin) / 2;

      notFired = (AmmoAmount - fired);

      damage   = notFired * averageDamage;
      radius   = 400;
      momentum = class'XWeapons.SniperFire'.default.Momentum;

      HurtRadius(damage, radius, class'DamTypeSniperShot', momentum, self.Location);
   }

   function FireWeapon()
   {
      local Actor    other;
      local Vector   hitLocation, hitNormal, endLocation, direction, momentum;
      local Rotator  fireRotation;
      local xEmitter emitter;
      local int      damage;

      fireRotation    = RotRand();
      direction   = Vector(fireRotation);
      endLocation = direction * 10000 + self.Location;

      other = self.Trace(hitLocation, hitNormal, endLocation, self.Location, true);

      if (other == none)
      {
         hitLocation = endLocation;
         hitNormal   = Normal(self.Location - endLocation);
      }
      else if (!other.bWorldGeometry && other != self)
      {
         damage = class'XWeapons.SniperFire'.default.DamageMin + Rand(class'XWeapons.SniperFire'.default.DamageMax - class'XWeapons.SniperFire'.default.DamageMin);
         momentum = hitNormal * class'XWeapons.SniperFire'.default.Momentum;
         other.TakeDamage(damage, self.Instigator, hitLocation, momentum, class'DamTypeSniperShot');
      }

      emitter = Spawn(class'XWeapons.NewLightningBolt', , , self.Location, Rotator(hitNormal));

      if (emitter != none)
      {
         emitter.mSpawnVecA = hitLocation;
      }
      else
      {
         Warn("Couldn't spawn lightning emitter.");
      }
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - fired) * TransientSoundVolume);

      effect = Spawn(class'RocketExplosion', instigator);
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

Begin:
   // Figure out how many bullets are going to be fired.
   // Somewhere between 50-100% of the bullets will be fired.
   fired = Rand(AmmoAmount / 2) + AmmoAmount / 2 + 1;

   SpawnExplosionEffect();

   HurtEverything();

   for (currentBullet = 0; currentBullet < fired; currentBullet++)
   {
      FireWeapon();

      if (currentBullet % 4 == 0)
      {
         Sleep(FRand() * 0.25);
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
