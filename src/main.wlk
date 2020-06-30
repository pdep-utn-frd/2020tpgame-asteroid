import wollok.game.*
class Asteroides {
	const images = ["asteroid.png", "asteroid_big1.png", "asteroid_medium3.png"].anyOne()
	var property position 
	method image() = images
	method queSos(){
		return 'asteroide'
	}
	method destruiObjeto(objetos){
		objetos.forEach{e => 
			if (e.queSos() == 'nave'){
			e.actualizarVida(30)
			}
		}
	}
	method colision(){
		if (game.hasVisual(self)){
		     self.destruiObjeto(game.colliders(self))
		    }
	}
	method avanza(){
			if (game.height() > self.position().y().abs()){
			position = self.position().down(0.5)
			self.colision()
			} else {
			game.removeTickEvent('asteroid')	
			}
	}
	method aparece(){
		const x = (0.. game.width()-2).anyOne() 
		const y = game.height()-1
		position = game.at(x,y)
		game.addVisual(self)
		game.onTick(100, 'asteroid',{=> self.avanza()})
	}
}
class Bala{
	var property position
	method nombreEvento() 
	method image()
	method queSos() = 'bala'
	method destruiObjeto(objetos)
	method desaparece(){
		if (game.hasVisual(self)){
				game.removeVisual(self)
				}
	}
	method avanza(hacia){
		if (game.height() > self.position().y().abs()){		
			 position = hacia
			 self.colision()
			 }  else {
		game.removeTickEvent(self.nombreEvento())
		}
	}
	method colision(){
		if (game.hasVisual(self)){
			 self.destruiObjeto(game.colliders(self))
			 }
	}

}
class BalaNave inherits Bala{
  	override method nombreEvento() = 'disparoNave'
	override method image() = "lasery.png"
	override method destruiObjeto(objetos){
		objetos.forEach{e => 
			if (e.queSos() == 'asteroide'){
			game.removeVisual(e)
			self.desaparece()
			}
			if (e.queSos() == 'enemigo'){
				self.desaparece()
				e.actualizarVida()
			}
		}
	}
	method disparar(){
		position = nave.position().up(1)
		game.addVisual(self)
		game.onTick(20, self.nombreEvento(), {=> self.avanza(self.position().up(1))}) 
	
	}
}

class BalaEnemigo inherits Bala{
  	  override method nombreEvento() = 'disparoEnemigo'
  	  override method image() = "laser_enemy.png"
	  override method destruiObjeto(objetos){
			objetos.forEach{e => 
			if (e.queSos() == 'nave'){
			self.desaparece()
			e.actualizarVida(80)
			}
		}
	}
		 method disparar(desdeNaveEnemiga){
	 	self.position(desdeNaveEnemiga.position()) 
	 	game.addVisual(self)
		game.onTick(20, self.nombreEvento(), {=> self.avanza(self.position().down(1))}) 
		}
   }

object juego {
	var property enemigosVivos = 1
	method configurate() {
		game.clear()
		game.title("Asteroid")
		game.width(15)
		game.height(15)
		game.boardGround("background.jpeg")
	 	game.addVisualCharacter(nave)
	 	nave.controles() 
	 	nave.vida(300)
	 	game.onTick(1000, 'generarAsteroides', {=> new Asteroides().aparece()})
		game.onTick(5000, 'generarEnemigo', {=> self.generarNuevoEnemigo() })
	 	const naveEnemiga = new Enemigo()
	 	naveEnemiga.aparece()

	}
	method generarNuevoEnemigo(){
		if (enemigosVivos < 2 ){
			new Enemigo().aparece()
			enemigosVivos += 1 
		}
	}
	method gameOver(){
		game.clear()
		game.addVisual(gameOver)
		keyboard.enter().onPressDo{	self.configurate()}
	}
}
object gameOver{
	method image() = 'gameOver.png'
	method position() = game.at(5,7)
}

object nave {
	var property vida 
	var property position = game.center() 
	method nuevoDisparo()  {
		new BalaNave().disparar()	
	}
	method queSos(){
		return 'nave'
	}
	method image() =  "nave.png"
	
	
	method controles(){
		keyboard.space().onPressDo{	self.nuevoDisparo()}
   }
   method actualizarVida(cantidad){
   	vida = vida - cantidad
   	if (vida > 0){
   	game.say(self, 'vida: ' + self.vida().toString())
   	} else {
   	juego.gameOver()
   	}
   }
}

class Enemigo {
	var property vida = 600
	var property position
	method image() = "enemy.png"
	method actualizarVida(){
	vida -=  80
	 if (vida > 0){
   	game.say(self, 'vida: ' + self.vida().toString())
   	} else {
    game.removeVisual(self)
    juego.enemigosVivos(juego.enemigosVivos() - 1)
   	}	
	}
	method aparece(){
		const x = (0.. game.width()-2).anyOne() 
		const y = game.height() -3
		position = game.at(x,y)
		self.puedoAparecerEn(position)
		game.onTick(800, 'disparar', {=> self.nuevoDisparo()})
		game.onTick(1000, 'movete', {=> self.cambiaPosicion()})

	}
		method puedoAparecerEn(posicion){
			if(game.getObjectsIn(posicion).size() == 0){
				game.addVisual(self)
			} else {
				self.cambiarCordenadas()
			}
		}
		method cambiarCordenadas(){
		const x = (0.. game.width()-2).anyOne() 
		const y = game.height() -3
		position = game.at(x,y)
		self.puedoAparecerEn(position)
		}
		method queSos(){
		return 'enemigo'
	}
		method cambiaPosicion(){
			if (nave.position().x() > self.position().x()){
				if (self.puedoMoverme(position.right(2))){
					self.position(position.right(1))  
				}
			} 
			if (nave.position().x() < self.position().x()){
				if (self.puedoMoverme(position.left(2))){
					self.position(position.left(1))
				}
			}
		}
		method puedoMoverme(direccion){
		return 	game.getObjectsIn(direccion).size() == 0 
		}
		method nuevoDisparo()  {
		if (game.hasVisual(self)){
		new BalaEnemigo().disparar(self)	
		}
	}
}