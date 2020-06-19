import wollok.game.*

class Bala {
	const orientacion = nave.orientacion()
	var property position = nave.position()
	
	method image() = orientacion.imageBala()
	
	method disparar(){
		position = nave.position()
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
	const property orientacion = up
	
	method nuevoDisparo()  {
		new Bala().disparar()	
	}
	
	method image() =  orientacion.imagen()
	
	method controles(){
		keyboard.space().onPressDo{	self.nuevoDisparo()}
   }
}


object up {
	method imageBala() = "lasery.png"
	method imagen() = "playerShip1_green-up.png"
	method trayectoriaBala(nombre) = nombre.position().up(1) 
}
