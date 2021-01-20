//=============================================================================
// ExplosiveMinigunAmmoPickup.
//=============================================================================
class ExplosiveMinigunAmmoPickup extends MinigunAmmoPickup;

var int     currentBullet;
var int     fired;
var Rotator fireRotation;
var  sound sounds[8];

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
               SpawnSmokeEffect(hitLocation + hitNormal * 9, Rotation);
            }
         }
         else if (other == self)
         {
            // Do nothing.
            //Log("Ouch! I hit myself!");
         }
      }
   }

   function HurtEverything()
   {
      local float damage, radius, momentum;

      damage   = (AmmoAmount - fired) * 17;
      radius   = 150;
      momentum = damage;

      HurtRadius(damage, radius, class'DamTypeMinigunBullet', momentum, Location);
   }

   function SpawnExplosionEffect()
   {
      local RocketExplosion effect;

      PlaySound(sound'WeaponSounds.BExplosion1', , SoundVolume * (AmmoAmount - fired) * TransientSoundVolume);

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

Begin:
   // Figure out how many bullets are going to be fired.
   // Somewhere between 50-100% of the bullets will be fired.
   fired = Rand(AmmoAmount / 2) + AmmoAmount / 2 + 1;

   // Then spawn a nice little explosion.
   SpawnExplosionEffect();

   // Next, hurt anything that's nearby.
   HurtEverything();

   // Sleep for a tick to let the explosions go off.
   Sleep(0.0);

   // Now shoot the bullets.
   for (currentBullet = 0; currentBullet < fired; currentBullet++)
   {
      fireRotation        = Rotation;
      fireRotation.Pitch += Rand(32767);
      fireRotation.Yaw    =  Rand(65535);
      fireRotation.Roll   =  Rand(65535);

      // Spawn a tracer with every Nth bullet.
      if (currentBullet % 3 == 0)
      {
         Spawn(class'TracerProjectile', , , Location, fireRotation);
         PlaySound(sounds[Rand(8)], , 1.0, , 800); // Random ricochet sound
      }

      TraceBullet(fireRotation);

      // Sleep for a short, variable length of time between bullet shots.
      // This gives it that nice chaotic look and feel.
      Sleep(FRand() * 0.04);
   }

   // Play some shell casing noises for effect
   Sleep(0.25); // A bit of wait to allow the ricochet sounds to stop
   PlaySound(sound'WeaponSounds.BaseGunTech.BShell1', , 1.0, , 800);
   Sleep(0.25);
   PlaySound(sound'WeaponSounds.BaseGunTech.BShell1', , 1.0, , 800);

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
   sounds[0] = sound'WeaponSounds.BBulletImpact2';
   sounds[1] = sound'WeaponSounds.BBulletImpact3';
   sounds[2] = sound'WeaponSounds.BBulletImpact4';
   sounds[3] = sound'WeaponSounds.BBulletImpact5';
   sounds[4] = sound'WeaponSounds.BBulletImpact6';
   sounds[5] = sound'WeaponSounds.BBulletImpact7';
   sounds[6] = sound'WeaponSounds.BBulletImpact8';
   sounds[7] = sound'WeaponSounds.BBulletImpact9';
}
