//=============================================================================
// ExplosiveClassicSniperAmmoPickup.
//=============================================================================
class ExplosiveClassicSniperAmmoPickup extends ClassicSniperAmmoPickup
   placeable;

var int        currentBullet;
var int        fired;
var sound      sounds[8];

// TODO: Look at the WeaponFire/ProjectileFire class hierarchy.

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

      averageDamage = (class'UTClassic.ClassicSniperFire'.default.DamageMax
         + class'UTClassic.ClassicSniperFire'.default.DamageMin) / 2;

      notFired = (AmmoAmount - fired);

      damage   = notFired * averageDamage;
      radius   = 400;
      momentum = class'UTClassic.ClassicSniperFire'.default.Momentum;

      HurtRadius(damage, radius, class'DamTypeClassicSniper', momentum, self.Location);
   }

   function FireWeapon()
   {
      local Actor    other;
      local Vector   hitLocation, hitNormal, endLocation, direction, momentum;
      local Rotator  fireRotation;
      local int      damage;
//      local SniperWallHitEffect    S;

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
         damage = class'UTClassic.ClassicSniperFire'.default.DamageMin
      + Rand(class'UTClassic.ClassicSniperFire'.default.DamageMax
         - class'UTClassic.ClassicSniperFire'.default.DamageMin);

         momentum = hitNormal * class'UTClassic.ClassicSniperFire'.default.Momentum;
         other.TakeDamage(damage, self.Instigator, hitLocation, momentum, class'DamTypeClassicSniper');
      }

/*
      if(other.bWorldGeometry)
      {
         S = Weapon.Spawn(class'SniperWallHitEffect',,, hitLocation, rotator(-1 * hitNormal));
         if ( S != None )
            S.FireStart = Start;
      }
*/
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - fired) * TransientSoundVolume);

      effect = Spawn(class'RocketExplosion');
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
      PlaySound(sounds[Rand(8)], , 1.0, , 800);

      if (currentBullet % 4 == 0)
      {
         Sleep(FRand() * 0.25);
      }
   }

   // Play some shell casing noises for effect
   for(currentBullet = 0; currentBullet < fired; currentBullet++)
   {
      PlaySound(sound'WeaponSounds.BaseGunTech.BShell1', , 1.0, , 800);

      Sleep(FRand() * 0.25);
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
   sounds[0] = sound'WeaponSounds.BBulletImpact2';
   sounds[1] = sound'WeaponSounds.BBulletImpact3';
   sounds[2] = sound'WeaponSounds.BBulletImpact4';
   sounds[3] = sound'WeaponSounds.BBulletImpact5';
   sounds[4] = sound'WeaponSounds.BBulletImpact6';
   sounds[5] = sound'WeaponSounds.BBulletImpact7';
   sounds[6] = sound'WeaponSounds.BBulletImpact8';
   sounds[7] = sound'WeaponSounds.BBulletImpact9';
}
