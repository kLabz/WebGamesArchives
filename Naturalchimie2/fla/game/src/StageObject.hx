import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import Game.GameStep ;
import GameData._ArtefactId ;
import mode.GameMode.TransformInfos ;
import Const.Art ;


enum DestroyMethod {
	Flame(part : Bool) ;
	Warp ;
}



class StageObject {
	
	public var omc : ObjectMc ;
	public var pdm : mt.DepthManager ;
		
	public var id : Art ;
	public var x : Int ;
	public var y : Int ;
	public var isFalling : Bool ;
	public var target : {x : Int, y : Int} ;
	public var targetPos : {x : Float, y : Float} ;
	public var g : Float ;
	public var autoFall : Bool ;
	//public var inStock : Bool ;
	public var isParasit : Bool ;
	public var isPickable : Bool ;
	public var toKill : Bool ;
	public var curPick : PickUp ;
	public var pickTime : Float ;
	public var pickQty : mt.flash.Volatile<Int> ;
	public var showEffect : Bool ;
		
	
	public var isBouncing : Bool ;
	public var bouncer : Bool ;	
	var bTimer : Float ;
	var bWait : Float ; 
	var bSpeed : Float ;
	var bounceParam : Float ;
	var bounceHeight : Int ;
		
	//transformation
	public var tfInfos : TransformInfos ;
	var tfParts : Array<Phys> ;
		
	public var helpTxt : String ;
		
	public var destroyMethod : DestroyMethod ;
	public var destroyTimer : Float ;
	public var destroyWait : Float ;
	var destroySound : String ;
	public var destroyStep : Int ;
	public var fEndDestroy : Void -> Void ;
		
	public var effectTimer : Float ;
	public var effectStep : Int ;
		
	public var group : Array<StageObject> ;
	
	
	public function new() {
		isFalling = false ;
		
		isBouncing = false ;
		bouncer = false ;
		
	//	onTransform = false ;
		autoFall = false ;
		//inStock = false ;
		toKill = false ;
		showEffect = false ;
		
		isParasit = false ;
		isPickable = false ;
		
		Game.objectsList.push(this) ;
	}
	
	
	public function checkHelp() {
		if (Game.me.data._helps != null)  {
			for (h in Game.me.data._helps) {
				if (!Type.enumEq(h._id, this.getArtId()))
					continue ;
				this.helpTxt = h._help ;
				break ;
			}
		}
	}
	
	
	public function setOmc(no : ObjectMc) {
		if (omc != null)
			omc.kill() ;
		omc = no ;
		omc.updateId(Const.fromArt(id)) ;
	}
	
	public static function get(a : _ArtefactId, dm : mt.DepthManager, d : Int, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) : StageObject {
		switch(a) {
			case _Elt(n) : //### DEV ONLY
				//trace("deprecated") ;
				//return null ;
				return new Element(n, dm, d, noOmc, null, withBmp, sc) ;
			case _Dynamit(s) :
				return new artefact.Dynamit(s, dm, d, noOmc, withBmp, sc) ; 
			case _Alchimoth :
				return new artefact.Alchimoth(dm, d, noOmc, withBmp, sc) ; 
			case _Destroyer(eid) : 
				return new artefact.Destroyer(eid, dm, d, noOmc, withBmp, sc) ; 
			case _Protoplop(l) :
				return new artefact.ProtoPlop(l, dm, d, noOmc, withBmp, sc) ; 
			case _PearGrain(l) :
				return new artefact.PearGrain(l, dm, d, noOmc, withBmp, sc) ; 
			case _Jeseleet(l) :
				return new artefact.Jeseleet(l, dm, d, noOmc, withBmp, sc) ; 
			case _RazKroll : 
				return new artefact.RazKroll(dm, d, noOmc, withBmp, sc) ; 
			case _Delorean(level) : 
				return new artefact.Delorean(level, dm, d, noOmc, withBmp, sc) ; 
			case _Dollyxir(level) : 
				return new artefact.Dollyxir(level, dm, d, noOmc, withBmp, sc) ; 
			case _Detartrage : 
				return new artefact.Detartrage(dm, d, noOmc, withBmp, sc) ; 
			case _Teleport : 
				return new artefact.Teleport(dm, d, noOmc, withBmp, sc) ; 
			case _Tejerkatum : 
				return new artefact.Tejerkatum(dm, d, noOmc, withBmp, sc) ; 
			case _PolarBomb : 
				return new artefact.PolarBomb(dm, d, noOmc, withBmp, sc) ; 
			case _Pistonide : 
				return new artefact.Pistonide(dm, d, noOmc, withBmp, sc) ; 
			case _Grenade(l) : 
				return new artefact.Grenade(l, dm, d, noOmc, withBmp, sc) ; 
			case _Neutral : 
				return new artefact.Neutral(dm, d, noOmc, null, withBmp, sc) ;
			case _Catz : 
				return new artefact.Catz(dm, d, noOmc, withBmp, sc) ;
			case _SnowBall : 
				return new artefact.SnowBall(dm, d, noOmc, withBmp, sc) ;
			case _Choco : 
				return new artefact.Choco(dm, d, noOmc, withBmp, sc) ;
			case _Empty : 
				return new artefact.Empty(dm, d, noOmc, withBmp, sc) ;
			case _Block(level) : 
				return new artefact.EnforcedBlock(level, dm, d, noOmc, withBmp, sc) ;
			case _CountBlock(level) : 
				return new artefact.CountBlock(level, dm, d, noOmc, withBmp, sc) ;
			case _Dalton : 
				return new artefact.DaltonianParadise(dm, d, noOmc, withBmp, sc) ;
			case _Wombat :
				return new artefact.WombatAttack(dm, d, noOmc, withBmp, sc) ;
			case _MentorHand :
				return new artefact.MentorHand(dm, d, noOmc, withBmp, sc) ;
			case _Patchinko :
				return new artefact.Patchinko(dm, d, noOmc, withBmp, sc) ;
			case _QuestObj(id) :
				return new artefact.QuestObject(id, dm, d, noOmc, withBmp, sc) ;
			case _DigReward(o) :
				return new artefact.DigReward(o, dm, d, noOmc, withBmp, sc) ;
			case _Pumpkin(id) : 
				return new artefact.Pumpkin(id, dm, d, noOmc, withBmp, sc) ;
			case _NowelBall : 
				return new artefact.NowelBall(dm, d, noOmc, null, withBmp, sc) ;
			case _Slide(level) : 
				return new artefact.Slide(level, dm, d, noOmc, withBmp, sc) ; 
			case _Skater : 
				return new artefact.Skater(dm, d, noOmc, withBmp, sc) ;
			case _Pa, _Stamp, _Joker, _GodFather, _Unknown, _Gift : 
				//trace("invalid stageObject : " + a) ;
				return null ;
			case _Surprise(level)  : 
				return null ;
			case _Elts(x, y) : 
				//trace("invalid stageObject : " + a) ;
				return null ;
			case _Sct(sid) : 
				//trace("invalid stageObject : " + a) ;
				return null ;
			/*default : 
				trace("invalid stageObject : " + a) ;
				return null ;*/
		}
	}
	
	
	
	public function copy(dm : mt.DepthManager, ?depth : Int = 2) : StageObject {
		var c : StageObject = null ;
		
		switch(Const.fromArt(id)) {
			case _Elt(n) :
				c = new Element((cast this).index, dm, depth, null, (cast this).r, omc.getBmp(), omc.initScale) ;		
			case _Dynamit(s) :
				c = new artefact.Dynamit((cast this).value, dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Alchimoth :
				c = new artefact.Alchimoth(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Destroyer(eid) : 
				c = new artefact.Destroyer((cast this).targetId[0], dm, depth, null, omc.getBmp(), omc.initScale) ; //[0] cause to volatile
				(cast c).gTimer = (cast this).gTimer ;
			case _Protoplop(l) :
				c = new artefact.ProtoPlop(l, dm, depth, null, omc.getBmp(), omc.initScale) ;
				(cast c).gTimer = (cast this).gTimer ;
			case _PearGrain(l) :
				c = new artefact.PearGrain(l, dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Jeseleet(l) :
				c = new artefact.Jeseleet(l, dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _RazKroll : 
				c = new artefact.RazKroll(dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Dollyxir(l) :
				c = new artefact.Dollyxir(l, dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Detartrage : 
				c = new artefact.Detartrage(dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Teleport : 
				c =  new artefact.Teleport(dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Tejerkatum : 
				c =  new artefact.Tejerkatum(dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _PolarBomb : 
				c =  new artefact.PolarBomb(dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Pistonide : 
				c =  new artefact.Pistonide(dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Grenade(l) : 
				c =  new artefact.Grenade(l, dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Delorean(l) :
				c = new artefact.Delorean(l, dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Neutral : 
				c = new artefact.Neutral(dm, depth, null, (cast this).rid, omc.getBmp(), omc.initScale) ;
			case _Catz : 
				c = new artefact.Catz(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _SnowBall : 
				c = new artefact.SnowBall(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Choco : 
				c = new artefact.Choco(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Block(level) : 
				c = new artefact.EnforcedBlock(level, dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _CountBlock(level) : 
				c = new artefact.CountBlock(level, dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Dalton : 
				c = new artefact.DaltonianParadise(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Wombat :
				c = new artefact.WombatAttack(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _MentorHand :
				c = new artefact.MentorHand(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Empty :
				c = new artefact.Empty(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Patchinko :
				c = new artefact.Patchinko(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _QuestObj(id) :
				c = new artefact.QuestObject(id, dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _DigReward(o) :
				c = new artefact.DigReward(o, dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Pumpkin(id) :
				c = new artefact.Pumpkin(id, dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _NowelBall : 
				c = new artefact.NowelBall(dm, depth, null, (cast this).rid, omc.getBmp(), omc.initScale) ;
			case _Slide(l) : 
				c = new artefact.Slide(l, dm, depth, null, omc.getBmp(), omc.initScale) ; 
			case _Skater : 
				c =  new artefact.Skater(dm, depth, null, omc.getBmp(), omc.initScale) ;
			case _Pa, _Stamp, _Joker, _Unknown, _Gift : 
				trace("invalid stageObject : " + id) ;
				return null ;
			case _Surprise(level) : 
				trace("invalid stageObject : " + id) ;
				return null ;
				return null ;
			case _GodFather : 
				trace("invalid stageObject : " + id) ;
				return null ;
			case _Elts(x, y) : 
				trace("invalid stageObject : " + id) ;
				return null ;
			case _Sct(sid) : 
				trace("invalid stageObject : " + id) ;
				return null ;
		}
		
		c.isFalling = isFalling ;
		return c ;	
	}
	
	
	
	public function isCollateral(?e : _ArtefactId) : Bool {
		return isParasit || isPickable ;
	}
	
	
	public function place(px : Int, py : Int, ?mx : Float, ?my : Float) {
		x = px ;
		y = py ;		
		if (mx == null)
			mx = x * Const.ELEMENT_SIZE ;
		if (my == null)
			my = y * Const.ELEMENT_SIZE ;
		
		omc.mc._x = mx ;
		omc.mc._y = my ;
	}
	
	
	public function swapTo(d : Int) {
		pdm.swap(omc.mc, d) ;
	}

	
	public function setFall(dx : Int, dy : Int) {
		target = {x : dx, y : dy} ;
		targetPos = {x : Stage.X + target.x * Const.ELEMENT_SIZE, y : Const.HEIGHT - (Stage.BY + (target.y + 1) * Const.ELEMENT_SIZE)} ;
		if (isFalling) 
			return ;
		isFalling = true ;
		stopBounce() ;
		swapTo(Stage.HEIGHT - dy) ;
		Game.me.stage.falls.push(this) ;
		g = 1.4 ;
	}
	
	public function prepareBounce(h : Int) {
		//return ;
		
		bouncer = true ;
		bounceHeight =  h ;
	}
	
	public function initBounce() {
		//return ;
		
		bouncer = false ;
		var bSpeedMod = (Std.random(2) * 2 - 1) * Std.random(10) / 1000 ;
		
		
		/*if (bounceHeight < 3)
			deep -= Std.random(2) + 1 ;*/
		
		//bounceHeight += (Std.random(2) * 2 - 1) * Std.random(4) ;
		//bounceHeight = 14 ;
	//	trace(x + " # " + y + " ==> " + bounceHeight) ;
		var deep = 3 ;
		for(i in 0... y + 1) {
			if (y - i < 0)
				continue ;
			var o = Game.me.stage.grid[x][y - i] ;
			if (o == null)
				continue ;
			
			var p = Math.max(3, Math.min(bounceHeight + Math.max(0, (Const.BOUNCE_DEEP - i) * 2), 13)) ;
			
			p *= 1.8 ;
		
			var end = false ;
			if (o.targetPos == null)
				deep-- ;
			
			o.setBounce(i, p, bSpeedMod) ;
			
			if (deep <= 0)
				break ;
		}
		bounceHeight = null ;
	}
	
	
	public function setBounce(deep : Int, p : Float, ?speedMod = 0.0) {
		isBouncing = true ;
		bTimer = 0.0 ;
		bWait = deep / 5 ;
		bWait = null ;
		bounceParam = p ;
		bSpeed = speedMod ;
		
		if (targetPos == null) {
			targetPos = {x : omc.mc._x, y : omc.mc._y} ;
			/*if (y == 0)
				bounceParam /= 3.5 ;
			else
				bounceParam /= 2.5 ;*/
			if (y == 0)
				bounceParam /= 2.5 ;
			else
				bounceParam /= 1.8 ;
		} else {
			if (y == 0)
				bounceParam = 4 ;			
		}
		
		//trace(x + " # " + y + " bounceParam " + bounceParam) ;
		
		bounce() ;
	}
	
	
	public function bounce() {
		if (!isBouncing)
			return ;
		
		if (bWait != null) {
			bWait = Math.max(bWait - (0.04 + bSpeed) * mt.Timer.tmod, 0.0) ;
			if (bWait == 0.0) {
				bWait = null ;
				return ;
			}
		}
		
		bTimer = Math.min(bTimer + (0.04 + bSpeed) * mt.Timer.tmod, 1.0) ;
		
		var bt = 1 - bTimer ;
		/*var delta = null ;
		var a = 0.0 ;
		var b = 1.0 ;
		while (true) {
			if (bt >= (7 - 4 * a) / 11) {
				delta = -Math.pow((11- 6*a - 11 * bt) / 4, 2) + b*b ;
				break ;
			}
			a += b ;
			b /= 2.0 ;
		}
		*/
		var pa = 1.0 ;
		var delta = Math.pow(2, 10 * --bt) * Math.cos(20 * bt * Math.PI * pa / 3);
		
		delta = 1 - delta ;
		
		omc.mc._y = targetPos.y - bounceParam * (1 - delta) ;
		
	//	trace(x + " # " + y + " ### " + bTimer + "### delta : " + delta + " # " + omc.mc._y) ;

		
		if (bTimer == 1.0)
			stopBounce() ;
	}
	
	
	public function stopBounce()  {
		if (!isBouncing) 
			return ;
		isBouncing = false ;
		bTimer = null ;
		if (isFalling)
			return ;
		target = null ;
		targetPos = null ;
	}
	
	
	
	public function update() {
		bounce() ;
	}
	
	
	public function updateTransform() {
		if (effectStep == null) {
			trace(x + ", " + y + " don't want to be transformed ! ") ;
			return false ;
		}
				
		switch (effectStep) {
			case 0 :
				if (warm())
					effectStep = 3 ;
			
			case 2 : 
				if (colder())
					return false ;
			case 3 : 
				if (disappear()) {
					Game.me.stage.remove(this) ;
					return false ;
				}
		}
		return true ;
	}
	
	
	public function ungroup() {
		if (group == null) {
			return ;
		}
		group.remove(this) ;
		group = null ;
	}
	
	
	public function setGroup(g : Array<StageObject>, ?force = false) {
		if (group != null )  {
			if (!force) {
				trace("already in group on " + x + ", " + y) ;
				throw "already in group on " + x + ", " + y ;
			} else
				ungroup() ;
		}
		
		
		
		g.push(this) ;
		group = g ;
		
	}
	
	
	public function getArtId() : _ArtefactId {
		return Const.fromArt(id) ;
	}
	
	
	public function fall() {
		var t = Math.min((10.0 + g) * mt.Timer.tmod, targetPos.y - omc.mc._y) ;
		g = Math.min(g * g, 25.0) ;
				
		omc.mc._y += t ;
		
		if (targetPos.y - omc.mc._y < 4) {
			omc.mc._y = targetPos.y ;
			omc.mc._x = targetPos.x ;
			Game.me.stage.removeFall(this) ;
			x = target.x ;
			y = target.y ;
			isFalling = false ;
			/*targetPos = null ;
			target = null ;*/
			
			
			onGround() ;
			
			if (bouncer)
				initBounce() ;
		}
		
	}
	
	
	//to override for special effects
	public function onClick(pos : Int) { //declencheur sur un clic de l'objet ==> utilisation depuis l'inventaire
		
		var g = new Group(getArtId(), true) ;
		Group.forceNext(g) ;
		
		return true ;
	}
	
	
	public function onStage() { //declencheur sur le toStage
		if (helpTxt == null) {
			
			if (Game.me.stage.isVisibleMcEffect() && !Game.me.stage.mcEffect.toHide) {
				if (!Game.me.stage.isMcSpecialEffect()) {
					if (Game.me.stage.hasCurrentEffect()) {
						if (Game.me.stage.isFinishedEffect()) {
							Game.me.stage.killEffect() ;
						} else {
							Game.me.stage.forceCurrentEffect() ;
						}
					} else {
						if (Game.me.stage.isFinishedEffect())
							Game.me.stage.killEffect(null, null, true) ;
						Game.me.stage.hideMcEffect(this) ;
					}
				} else {
					if (Game.me.stage.isFinishedEffect()) {
						Game.me.stage.killEffect() ;
					}
				}
			}
		
		} else {
			if (Game.me.stage.isVisibleMcEffect()) {
				Game.me.stage.forceEffect(this) ;
			} else
				Game.me.stage.showMcEffect(this) ;
			showEffect = true ;
		}
	}
	
	
	public function onFall() { //declencheur sur le startFall
		//nothing todo
		return false ;
	}
	
	
	public function onTransform() { //declencheur sur initTransform/initPickUp/initKill
		//nothing todo
		return false ;
	}
	
	
	
	
	public function onGround() { //declencheur sur l'arrivée au sol
		Game.me.sound.play("chute_choc") ;
		
		var o = Game.me.stage.grid[x][y - 1] ;
		if (o != null && Type.enumEq(o.getArtId(), _Grenade(1))) {
			(cast o).onCover() ;
			return true ;
		}
		
		return false ;
	}
	
	
	public function onStageKill() {
		//nothing to do
	}
	
	
	public function updateEffect() { //update function for artefact special effects
		//nothing to do
	}
	
	
	public function toDestroy(method : DestroyMethod, ?wait : Float, ?sound : String) {
		if (destroyMethod != null)
			return ;
		
		destroyTimer = 100 ;
		destroyMethod = method ;
		destroyStep = 0 ;
		if (sound != null)
			destroySound = sound ;
		Game.me.stage.toDestroy.push(this) ;
		if (wait == null) {
			destroyWait = 0 ;
			//updateDestroy() ;
			return ;
		}
		destroyWait = wait ;
	}
	
	
	public function updateDestroy() {
		if (destroyMethod == null || destroyWait == null) {
			trace("destroy Method or Wait is null ! " + Std.string(destroyMethod) + ", " + Std.string(destroyTimer)) ;
			endDestroy() ;
			return ;
		}
		
		if (destroyWait > 0) {
			destroyWait -= mt.Timer.tmod ;
			return ;
		}
		
		switch(destroyMethod) {
			case Flame(part) :
				if (part)
					Game.me.sound.play(if (destroySound != null) destroySound else "transmutation_destructrice") ;
				var c = getCenter() ;
				var fmc = Game.me.mdm.attach("explosion", Const.DP_ANIM) ;
			
				fmc._x = c.x ;
				fmc._y = c.y ;
				fmc._rotation = Math.random() * 360 ;
				endDestroy() ;
				
				if (part) {
					var dm = Game.me.mdm ;
					var nbParts = 8 ;
					for(i in 0...nbParts) {
						var mc = dm.attach("parts", Const.DP_PART) ;
						mc.blendMode = "add" ;
						mc._xscale = mc._yscale = 40 + Std.random(30) ;
						var sp = new Phys(mc) ;
						var a = Math.random()*6.28 ;
						var ca = Math.cos(a) ;
						var sa = Math.sin(a) ;
						
						var speed = 12 + Math.random() * 12 ;
						sp.x = c.x + ca * 4 ;
						sp.y = c.y + sa * 4 ;
						sp.vx = ca * speed ;
						sp.vy = sa * speed ;
						sp.frict = 0.85 ;
						sp.fadeType = 6 ;
						sp.timer = 10 + Std.random(30) ;
						sp.weight = 0.35 ;
					}
				}
			
			case Warp :
				switch(destroyStep) {
					case 0 : //scale out
						destroyTimer = Math.max(destroyTimer - 5.7 * mt.Timer.tmod, 0) ;
					
						var delta = anim.TransitionFunctions.quart((100 - destroyTimer) / 100) ;
					
						//if (delta < omc.mc.smc.smc._xscale) {
							omc.mc.smc.smc._xscale= Std.int(Math.max(100 - delta * 100, 0)) ;
							omc.mc.smc.smc._yscale= omc.mc.smc.smc._xscale ;
						//}
						
						if (destroyTimer == 0) {
							destroyStep = 1 ;
							Game.me.sound.play("shake") ;
						}

					case 1 : //halo
						//setHalo(null, 1.4, 9) ;
						var mc = Game.me.mdm.attach("vanish", Const.DP_PART) ;
						mc._x = this.omc.mc._x + Const.ELEMENT_SIZE / 2 ;
						mc._y = this.omc.mc._y + Const.ELEMENT_SIZE / 2 ;
						var p = new Phys(mc) ;
						p.timer = 20 ;
						endDestroy() ;
	
				}
		}
		
	}
	
	public function endDestroy() {
		Game.me.stage.toDestroy.remove(this) ;
		destroyTimer = null ;
		
		if (fEndDestroy != null)
			fEndDestroy() ;
		else
			Game.me.stage.remove(this) ;
	}
	
	
	
	public function initPickUp(t : Float, ?force = false) {
		effectTimer = 100 ;
		effectStep = 0 ;
		pickTime = t ;
				
		curPick = Game.me.initPickUp(force) ;
	}
	
	
	public function forcePickUp(t : Float) {
		isPickable = true ;
		Game.me.stage.killParasits.push(this) ;
		initPickUp(t) ;
	}
	
	
	public function updatePickUp() {	
		switch (effectStep) {
			case 0 :
				if (warm(null, Const.PICK_COLOR)) {
					curPick.addParts(explode(Const.PICK_COLOR), this.getArtId(), this.pickTime, this.pickQty) ;
					effectStep = 1 ;
				}
				
			case 1 : 
				if (disappear()) {
					Game.me.stage.remove(this) ;
					return false ;
				}				
		}
		return true ;
	}
	
	
	public function getCenter() {
		return {x : omc.mc._x + Const.ELEMENT_SIZE / 2,
			y : omc.mc._y + Const.ELEMENT_SIZE / 2} ;
	}
	
	public function isElement() {
		switch(Const.fromArt(id)) {
			case _Elt(i) : return true ;
			case _Empty : return true ;
			default : return false ;
		}
	}

	
	public function kill() {
		ungroup() ;
		Game.objectsList.remove(this) ;
		
		if (omc != null)
			omc.kill() ;
	}
	
	
	//EFFECTS 
	public function warm(?speed : Float = 20.0, ?color) : Bool {
		if (effectTimer == null)
			effectTimer = 100 ;
		
		if (color == null)
			 color = 0xFFFFFF ;
				
		effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;
		Col.setPercentColor(omc.mc, 100 - effectTimer, color) ;
		return effectTimer == 0 ;
	}
	
	
	public function blink(?speed : Float = 10.0) : Bool {
		if (effectTimer == null)
			effectTimer = 100 ;
		effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;
		omc.mc._alpha = if (omc.mc._alpha < 50) 100 else 20 ;
		return effectTimer == 0 ;
	}
	
	
	function explode(?color) : Array<Phys> {
		if (color == null)
			 color = 0xFFFFFF ;
		var c = getCenter() ;
		
		var dm = if (Game.me.step == GameOver) Game.me.rdm else Game.me.mdm ;
		
		var explode = dm.attach("transformExplosion", Const.DP_PART) ;
		explode.blendMode = "overlay" ;
		//Col.setPercentColor(explode, 70, color) ;
		explode._rotation = Math.random()*360 ;
		explode._x = c.x ;
		explode._y = c.y ;
		explode._xscale = 60 + Math.random()*30 ;
		explode._yscale = explode._xscale ;

		var nbParts = 6 ;
		var res = new Array() ;
		for(i in 0...nbParts) {
			var mc = dm.attach("transformPart", Const.DP_PART) ;
			if (Std.random(3) == 0)
				mc.blendMode = "overlay" ;
			Col.setPercentColor(mc, 100, color) ;
			var sp = new Phys(mc) ;
			var a = Math.random()*6.28 ;
			var ca = Math.cos(a) ;
			var sa = Math.sin(a) ;
			
			var speed = 4 + Math.random() * 8 ;
			sp.x = c.x + ca * 4 ;
			sp.y = c.y + sa * 4 ;
			sp.vx = ca * speed ;
			sp.vy = sa * speed ;
			sp.frict = 0.9 ;
			sp.scale = 50 + Math.random() * 50 ;
			res.push(sp) ;
		}
		
		return res ;
	}
	
	
	function colder() : Bool {
		effectTimer =  Math.min((effectTimer * Math.pow(1.2, mt.Timer.tmod)) + 2, 100) ;
		Col.setPercentColor(omc.mc,100 - effectTimer,0xFFFFFF) ;
		return effectTimer == 100 ;
	}
	
	
	function disappear() {
		omc.mc._alpha = Math.max(omc.mc._alpha - 20 * mt.Timer.tmod, 0) ;
		return omc.mc._alpha == 0 ;
	}
	
	
	public function setHalo(?scale = 40, ?vsc = 1.3, ?timer = 8, ?dx = 0.0, ?dy = 0.0) {
		var c = getCenter() ;
		var hmc = Game.me.mdm.attach("transformCircle", Const.DP_PART) ;
		hmc._alpha = Math.random() * 60 + 40 ;
		var halo = new Phys(hmc) ;
		halo.x = c.x + dx ;
		halo.y = c.y + dy ;
		halo.setScale(scale) ;
		halo.vsc = vsc ;
		halo.timer = timer ;

		halo.fadeType = 6 ;
	}
	
	
	function resonance(t : Float, ?inner = false) {
		/*var dt = (1 - t / 100) * 6.28 * 6;
		omc.mc.smc.smc._xscale = 100 + Math.sin(dt) * 15 ;
		omc.mc.smc.smc._yscale = omc.mc.smc.smc._xscale ;*/
		
		//trace("resonance : " + dt + " # "+ omc.mc.smc.smc._xscale) ; 
					
		var c = getCenter() ;
		for(i in 0...2) {
			var mc = pdm.attach("transformPart", Const.DP_PART) ;
			var sp = new Phys(mc) ;
			var a = Math.random() * 6.28 ;
			var ca = Math.cos(a) ;
			var sa = Math.sin(a) ;
			
			var speed = 2 + Math.random() * 3 ;
			if (inner) {
				sp.x = c.x + ca * (30 + Std.random(20))  ;
				sp.y = c.y + sa * (30 + Std.random(20)) ;
				sp.vx = ca * speed * -1.5 ;
				sp.vy = sa * speed * -1.5 ;
				
				sp.vsc = 0.7 ;
				sp.timer = 30 + Math.random() * 10 ;
			} else {
				sp.x = c.x + ca * 5 ;
				sp.y = c.y + sa * 5 ;
				sp.vx = ca * speed ;
				sp.vy = sa * speed ;
				
				sp.vsc = 0.9 ;
				sp.timer = 10 + Math.random() * 10 ;
			}
			sp.weight = -0.3 + Math.random() * 0.6 ;
			sp.frict = 0.95 ;
			
			
			sp.vr = Math.random() * 10 ;
			sp.fadeType = 6 ;
			
			//Filt.blur(sp.root, 5, 5) ;
		}
	}
	
}