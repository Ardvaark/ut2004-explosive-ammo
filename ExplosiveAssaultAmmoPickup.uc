//=============================================================================
// ExplosiveAssaultAmmoPickup.
//=============================================================================
class ExplosiveAssaultAmmoPickup extends AssaultAmmoPickup;

// It sucks that these cannot be locals...
var   int  currentBullet;
var   int  firedBullets;
var   int  firedGrenades;
var() int  BulletCount;
var  sound sounds[8];
var Rotator fireRotation;

function TakeDamage(int damage, Pawn eventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
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

   function TraceBullet(Rotator rotation)
   {
      local Actor other;
      local Vector hitLocation, hitNormal, endLocation, direction;

      // Turn the rotation of the bullet into a vector, and
      // then add that to the start location to determine where
      // the trace should end.
      direction = vector(rotation);
      endLocation = direction * 10000 + location;

      other = Trace(hitLocation, hitNormal, endLocation, location, true);

      if (other != none)
      {
         if (other.bWorldGeometry)
         {
            // Spawn some smoke or something.
            //Log("Trace hit world geometry.");

            SpawnSparkEffect(hitLocation, Rotator(hitNormal));
         }
         else if (other != self)
         {
            //Log("Trace hit " $ other);
            other.TakeDamage(17, instigator, hitLocation, 3000 * direction, class'DamTypeMinigunBullet');

            if (!other.IsA('Pawn'))
            {
               SpawnSmokeEffect(hitLocation, Rotator(hitNormal));
            }
         }
         else if (other == self)
         {
            // Do nothing.
            //Log("Ouch! I hit myself!");
         }
      }
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - firedGrenades) * TransientSoundVolume);

      effect = Spawn(class'RocketExplosion', instigator);
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

   function SpawnSparkEffect(Vector effectLocation, Rotator effectRotation)
   {
      local WallSparks effect;

      effect = Spawn(class'WallSparks', instigator, , effectLocation, effectRotation);
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

   function SpawnSmokeEffect(Vector effectLocation, Rotator effectRotation)
   {
      local pclImpactSmoke effect;

      effect = Spawn(class'pclImpactSmoke', instigator, , effectLocation, effectRotation);
      effect.RemoteRole = ROLE_SimulatedProxy;
   }

   function TossGrenades()
   {
      local int i;

      // From 1 to all of the grenades will be fired.
      firedGrenades = Rand(AmmoAmount) + 1;

      for (i = 0; i < firedGrenades; i++)
      {
         Spawn(class'Grenade', instigator, , location, RotRand()).Speed = RandRange(0.1, 1.0);
      }
   }

   function HurtEverything()
   {
      local float damage, radius, momentum;

      damage = (BulletCount - firedBullets);
      damage += ((AmmoAmount - firedGrenades) * class'Grenade'.default.Damage) / 2;

      radius = class'Grenade'.default.DamageRadius;

      momentum = class'Grenade'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'DamTypeAssaultGrenade', momentum, Location);
   }

Begin:
   // Then spawn a nice little explosion.
   SpawnExplosionEffect();

   // Next, hurt anything that's nearby.
   HurtEverything();

   // Sleep for a tick so that the hurt can go off before
   // the grenades.
   Sleep(0.0);

   // Then spawn the grenades.
   TossGrenades();

   // Now shoot the bullets.
   // Figure out how many bullets are going to be fired.
   // Somewhere between 50-100% of the bullets will be fired.
   firedBullets = Rand(BulletCount / 2) + BulletCount / 2 + 1;

   // There are 50 bullets in a assault ammo pack.  It doesn't seem to be stored in
   // a variable anywhere, though.... :-(

   for (currentBullet = 0; currentBullet < firedBullets; currentBullet++)
   {
      fireRotation = RotRand();

      // Spawn a tracer with every Nth bullet.
      if (currentBullet % 5 == 0)
      {
         Spawn(class'TracerProjectile', , , Location, fireRotation);
         PlaySound(sounds[Rand(8)], , 1.0, , 800);
      }

      TraceBullet(fireRotation);

      // Sleep for a short, variable length of time between bullet shots.
      // This gives it that nice chaotic look and feel.
      Sleep(FRand() * 0.04);
   }

   // Play some shell casing noises for effect
   firedBullets /= 4;
   for(currentBullet = 0; currentBullet < firedBullets; currentBullet++)
   {
      PlaySound(sound'WeaponSounds.BaseGunTech.BShell1', , 1.0, , 800);

      Sleep(FRand() * 0.10);
   }

   // Now call the SetRespawn() method to send
   // the pickup back to sleep and wait for the respawn.
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
   BulletCount = 50;

   sounds[0] = sound'WeaponSounds.BBulletImpact2';
   sounds[1] = sound'WeaponSounds.BBulletImpact3';
   sounds[2] = sound'WeaponSounds.BBulletImpact4';
   sounds[3] = sound'WeaponSounds.BBulletImpact5';
   sounds[4] = sound'WeaponSounds.BBulletImpact6';
   sounds[5] = sound'WeaponSounds.BBulletImpact7';
   sounds[6] = sound'WeaponSounds.BBulletImpact8';
   sounds[7] = sound'WeaponSounds.BBulletImpact9';
}
