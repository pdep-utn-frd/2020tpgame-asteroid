import wollok.game.*
class Asteroides {
	var property vida = 100
	var property position 
	method image() = "asteroid.png"
	method queSos(){
		return 'asteroide'
	}
	method destruiObjeto(objetos){
		objetos.forEach{e => 
			if (e.queSos() == 'nave'){
			juego.gameOver()
			}
		}
	}
	method aparece(){
		const x = (0.. game.width()-2).anyOne() 
		const y = game.height()-1
		position = game.at(x,y)
		game.addVisual(self)
		game.onTick(200, 'asteroid',{=> 
			if (game.height() > self.position().y().abs()){
			position = self.position().down(1)
			if (game.hasVisual(self)){
		       self.destruiObjeto(game.colliders(self))
		    }
			} else {
			game.removeTickEvent('asteroid')	
			}
		})
	}
}
class Bala {
	var property position = nave.position()
	method queSos(){
		return 'bala'
	}
	method destruiObjeto(objetos){
		objetos.forEach{e => 
			if (e.queSos() == 'asteroide' && game.hasVisual(e)){
			game.removeVisual(e)
			}
		}
	}
	method image() = "lasery.png"
	method disparar(){
		position = nave.position()
		game.addVisual(self)
		game.onTick(20, 'disparo', {=>	
			if (game.height() > self.position().y().abs()){	
			 position =  self.position().up(1) 
			 self.destruiObjeto(game.colliders(self))
			 }  else {
		game.removeTickEvent('disparo')
		}	
		}) 
	
	}
}


object juego {
	method configurate() {
		game.clear()
		game.title("Asteroid")
		game.width(15)
		game.height(15)
		game.ground("blue.png")
	 	game.addVisualCharacter(nave)
	 	nave.controles() 
	 	game.onTick(600, 'generarAsteroides', {=> new Asteroides().aparece()})
	}
	method gameOver(){
		game.clear()
		game.addVisual(gameOver)
		keyboard.enter().onPressDo{	self.configurate()}
	}
}
object gameOver{
	method image() = 'gameOver.png'
	method position() = game.at(2,4)
}

object nave {
	var property position = game.center() 
	method nuevoDisparo()  {
		new Bala().disparar()	
	}
	method queSos(){
		return 'nave'
	}
	method image() =  "playerShip1_green-up.png"
	
	
	method controles(){
		keyboard.space().onPressDo{	self.nuevoDisparo()}
   }
}

