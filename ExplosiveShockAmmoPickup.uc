//=============================================================================
// ExplosiveShockAmmoPickup.
//=============================================================================
class ExplosiveShockAmmoPickup extends ShockAmmoPickup;

var int        currentBullet;
var int        fired;

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
      local ShockBeamEffect beamEffect;

      // Turn the rotation of the bullet into a vector, and
      // then add that to the start location to determine where
      // the trace should end.
      direction = vector(rotation);
      endLocation = direction * 10000 + location;

      other = Trace(hitLocation, hitNormal, endLocation, location, true);

      beamEffect = Spawn(class'ShockBeamEffect', , , Location, rotation);
      beamEffect.Instigator = none;
      beamEffect.AimAt(endLocation, hitNormal);

      if (other != none)
      {
         if (other.bWorldGeometry)
         {
            //Log("Trace hit world geometry.");
         }
         else if (other != self)
         {
            //Log("Trace hit " $ other);
            other.TakeDamage(17, instigator, hitLocation, 3000 * direction, class'DamTypeShockBeam');
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
      local int notFired;

      notFired = (AmmoAmount - fired);

      damage   = notFired * class'ShockProjectile'.default.Damage;
      radius   = notFired * class'ShockProjectile'.default.DamageRadius;
      momentum = notFired * class'ShockProjectile'.default.MomentumTransfer;

      HurtRadius(damage, radius, class'DamTypeShockCombo', momentum, Location);
   }

   function FireWeapon()
   {
      local Projectile currentProjectile;
      local Rotator    currentRotation;

      currentRotation = Rotation;
      currentRotation.Pitch += Rand(32767);
      currentRotation.Yaw    = Rand(65535);

      if (FRand() > 0.7)
      {
         currentProjectile = Spawn(class'ShockProjectile', Instigator, , Location, currentRotation);
         currentProjectile.Velocity = Vector(currentRotation) * class'ShockProjectile'.default.Speed * RandRange(0.8, 1.5);
      }
      else
      {
         TraceBullet(currentRotation);
      }
   }

Begin:
   // Figure out how many bullets are going to be fired.
   // Somewhere between 50-100% of the bullets will be fired.
   fired = Rand(AmmoAmount / 2) + AmmoAmount / 2 + 1;

   // Then spawn a nice little explosion.
   PlaySound(sound'WeaponSounds.ShockRifle.ShockComboFire', , 1.0, , 800);
   Spawn(class'ShockCombo', , , Location);

   // Next, hurt anything that's nearby.
   HurtEverything();

   // Sleep for a tick so that the hurt can go off before
   // the projectiles fire.
   Sleep(0.01);

   for (currentBullet = 0; currentBullet < fired; currentBullet++)
	{
      FireWeapon();

      if (currentBullet % 4 == 0)
      {
         Sleep(FRand() * 0.18);
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
