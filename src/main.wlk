import wollok.game.*
class Bala {
	var orientacion = nave.orientacion()
	var property position = nave.position()
	method image() = orientacion.imageBala()
	method disparar(){
		if (orientacion == up){
			position = nave.position()
		}
		if (orientacion == down){
		position = nave.position().down(4)
		}
		if (orientacion == left){
		position = nave.position().left(4)
		}

		game.addVisual(self)
		game.onTick(50, 'disparo', {=>	
			if (game.width().abs() > self.position().x().abs() && game.height() > self.position().y().abs()){	
			 position = orientacion.trayectoriaBala(self)
			 }  else {
		game.removeTickEvent('disparo')
		}	
		}) 

	}
}
object juego {
	method configurate() {
		game.title("Asteroid")
		game.width(15)
		game.height(15)
		game.ground("blue.png")
	 	game.addVisualCharacter(nave)
	 	nave.controles() 
	}
}

object nave {
	var property position = game.center() 
	var property orientacion = up
	method nuevoDisparo()  {
		new Bala().disparar()	
	}
	method image() =  orientacion.imagen()
		method controles(){
		keyboard.up().onPressDo{ self.mover(up)}
		keyboard.down().onPressDo{ self.mover(down)}
		keyboard.left().onPressDo{ self.mover(left)}
		keyboard.right().onPressDo{ self.mover(right)}
		keyboard.space().onPressDo{	self.nuevoDisparo()}
   }
	method mover(direccion){
		orientacion = direccion
	}	

}

object left { 
	method imageBala() = "laserx.png"
	method imagen() = "playerShip1_green-left.png"
	method trayectoriaBala(nombre) = nombre.position().left(1) 
}

object right { 
	method imageBala() = "laserx.png"
	method imagen() = "playerShip1_green-right.png" 
	method trayectoriaBala(nombre) = nombre.position().right(1) 
}

object down { 
	method imageBala() = "lasery.png"
	method imagen() = "playerShip1_green-down.png"
	method trayectoriaBala(nombre) = nombre.position().down(1) 
}

object up {
	method imageBala() = "lasery.png"
	method imagen() = "playerShip1_green-up.png" 
	method trayectoriaBala(nombre) = nombre.position().up(1) 
}



