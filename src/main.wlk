import wollok.game.*

class Bala {
	const orientacion = nave.orientacion()
	var property position = nave.position().up(1)
	
	method image() = orientacion.imageBala()
	
	method disparar(){
		position = nave.position().up(1)
		game.addVisual(self)
		
//		game.onTick(5,'colisionLaser',{=> self.Collide()})
		
		game.onTick(50, 'disparo', {=>	
			if (game.width().abs() > self.position().x().abs() && game.height() > self.position().y().abs()){	
			 position = orientacion.trayectoriaBala(self)
			 }  else {
		game.removeTickEvent('disparo') 
//		game.removeTickEvent('colisionLaser') 
		}	
		}) 
	}
	
//	method Collide(){
//		game.onCollideDo(self,{=> game.colliders(self).get(0).eliminar()  game.removeVisual(self) })
//	}
}

 
object juego {
	method configurate() {
		game.title("Asteroid")
		game.width(15)
		game.height(15)
		game.ground("blue.png")
	 	game.addVisualCharacter(nave) 
	 	nave.controles() 
	 	game.onTick(1000,'spawnEnemies', { => new Asteroid().spawn() })
	 	game.onTick(5,'colisionNave',{=> nave.Collide()})
	}
}


object nave {
	var property position = game.center() 
	const property orientacion = up
	
	method nuevoDisparo()  {
		new Bala().disparar()	 
	}
	method Collide(){
		if(not game.colliders(self).isEmpty()) game.stop() 
	}
	method image() =  orientacion.imagen()
	
	method controles(){
		keyboard.space().onPressDo{	self.nuevoDisparo()}
   }
   
  
}


class Asteroid {
	const orientacion = nave.orientacion()
	var property position = nave.position()
	method image() = orientacion.imageAst()	
	 
	
	method spawn(){ 
		position = game.at(1.randomUpTo(14),14)
		game.addVisual(self)
		game.onTick(1000, 'enemy', {=>	
			if (game.width().abs() > self.position().x().abs() && game.height() > self.position().y().abs()){	
			 position = orientacion.trayectoriaAst(self)
			 }  else {
		game.removeTickEvent('enemy')
		}	
		}) 
	}
	
//	
//	method eliminar(){
//		game.removeVisual(self)
//	}
}

object up {
	method imageBala() = "lasery.png"
	method imageAst() ="asteroids.png"
	method imagen() = "playerShip1_green-up.png"
	method trayectoriaBala(nombre) = nombre.position().up(1) 
	method trayectoriaAst(nombre) = nombre.position().down(1) 
}
