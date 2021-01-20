//=============================================================================
// MutExplosiveAmmo.
//=============================================================================
class MutExplosiveAmmo extends Mutator;

var globalconfig float  ShitFactor;
var localized    string ShitFactorDesc;
var localized    string ShitFactorDetailDesc;

static function FillPlayInfo(PlayInfo playInfo)
{
	super.FillPlayInfo(playInfo);

	playInfo.AddSetting(default.RulesGroup, "ShitFactor", default.ShitFactorDesc, 0, 0, "Text");
}

static event string GetDescriptionText(string propName)
{
   local string desc;
   
	switch (propName)
	{
   case "ShitFactor":
      desc = default.ShitFactorDetailDesc;
      break;
      
   default:
      desc = super.GetDescriptionText(propName);
	}

	return desc;
}

function bool CheckReplacement( Actor other, out byte bSuperRelevant )
{
	local bool keep;
	bSuperRelevant = 0;

	keep = true;

	if (other.IsA('ExplosiveBioAmmoPickup')
		|| other.IsA('ExplosiveRocketAmmoPickup')
		|| other.IsA('ExplosiveFlakAmmoPickup')
		|| other.IsA('ExplosiveLinkAmmoPickup')
		|| other.IsA('ExplosiveONSAVRiLAmmoPickup')
		|| other.IsA('ExplosiveShockAmmoPickup')
		|| other.IsA('ExplosiveONSGrenadeAmmoPickup')
		|| other.IsA('ExplosiveONSMineAmmoPickup')
		|| other.IsA('ExplosiveAssaultAmmoPickup')
		|| other.IsA('ExplosiveMinigunAmmoPickup')
		|| other.IsA('ExplosiveSniperAmmoPickup')
		|| other.IsA('ExplosiveClassicSniperAmmoPickup'))
	{
		Ammo(other).bCanBeDamaged = true;
		Ammo(other).bProjTarget = true;
	}
	else if (other.IsA('Ammo'))
        {
		keep = ReplaceAmmo(other);
	}

	return keep;
}

function bool ReplaceAmmo(Actor other)
{
	local bool keep;

	keep = false;

	if (other.IsA('BioAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveBioAmmoPickup");
	}
	else if (other.IsA('RocketAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveRocketAmmoPickup");
	}
	else if (other.IsA('FlakAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveFlakAmmoPickup");
	}
	else if (other.IsA('LinkAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveLinkAmmoPickup");
	}
	else if (other.IsA('ONSAVRiLAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveONSAVRiLAmmoPickup");
	}
	else if (other.IsA('ShockAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveShockAmmoPickup");
	}
	else if (other.IsA('ONSGrenadeAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveONSGrenadeAmmoPickup");
	}
	else if (other.IsA('ONSMineAmmoPickup'))
	{
		ReplaceWith(other, "ExplosiveAmmo.ExplosiveONSMineAmmoPickup");
	}
	else if (other.IsA('AssaultAmmoPickup'))
	{
      ReplaceWith(other, "ExplosiveAmmo.ExplosiveAssaultAmmoPickup");
	}
	else if (other.IsA('MinigunAmmoPickup'))
	{
      ReplaceWith(other, "ExplosiveAmmo.ExplosiveMinigunAmmoPickup");
	}
	else if (other.IsA('SniperAmmoPickup'))
	{
	   ReplaceWith(other, "ExplosiveAmmo.ExplosiveSniperAmmoPickup");
	}
	else if (other.IsA('ClassicSniperAmmoPickup'))
	{
	   ReplaceWith(other, "ExplosiveAmmo.ExplosiveClassicSniperAmmoPickup");
	}
	/*
   if (other.IsA('Ammo'))
   {
     ReplaceWith(other, "ExplosiveAmmo.ExplosiveSniperAmmoPickup");
   }
   */
	else
	{
		keep = true;
	}

	return keep;
}

static function ExplodeAmmo(Ammo ammo, class<Projectile> projectileClass, int count, float maxSpeed)
{
	local int i;
	local Projectile projectile;

	ammo.SetRespawn();
	ammo.bProjTarget = false;

	for (i = 0; i < (count); i++)
	{
		//Log("Creating projectile " $ ammo.ProjectileClass $ " " $ i $ "/" $ AmmoAmount);

		projectile = ammo.Spawn(projectileClass, ammo, , ammo.Location, ammo.RotRand());

		if (projectile != none)
		{
			projectile.Speed = ammo.RandRange(1.0, maxSpeed);
		}
		else
		{
			Warn("Unable to create projectile!");
		}
	}
}

static function ExplodeAmmoShock(Ammo ammo, class<Projectile> projectileClass, int count, float maxSpeed)
{
	local int i;
	local Projectile projectile;

	ammo.SetRespawn();
	ammo.bProjTarget = false;

	for (i = 0; i < (count); i++)
	{
		//Log("Creating projectile " $ ammo.ProjectileClass $ " " $ i $ "/" $ AmmoAmount);

		projectile = ammo.Spawn(projectileClass, ammo, , ammo.Location * ammo.Rand(4), ammo.RotRand());

		if (projectile != none)
		{
			projectile.Speed = ammo.RandRange(1.0, maxSpeed);
		}
		else
		{
			Warn("Unable to create projectile!");
		}
	}
}

defaultproperties
{
   FriendlyName         = "Explosive Ammo";
   Description          = "Makes ammo explode when you shoot it.  Watch your step!";
   GroupName            = "Ammo";
   ShitFactor           = 1.0;
   ShitFactorDesc       = "The \"Oh Shit!\" factor.";
   ShitFactorDetailDesc = "The number of projectiles normally launched by an ammo explosion will be multiplied by this factor.  BEWARE: Increasing this above 1.0 could really piss off the game engine!";
}
