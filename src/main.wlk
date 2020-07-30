import wollok.game.*

class Asteroides {

	const images = [ "asteroid.png", "asteroid_big1.png", "asteroid_medium3.png" ].anyOne()
	var property position

	method impactoBalaEnemiga(bala) {}

	method impactoAsteroide() {}

	method impactoBalaNave(bala) {
		bala.desaparece()
		self.desaparece()
	}

	method destruiObjetos(objetos) {
		objetos.forEach{ e => e.impactoAsteroide()}
	}

	method colision() {
		if (game.hasVisual(self)) {
			self.destruiObjetos(game.colliders(self))
		}
	}

	method desaparece() {
		if (game.hasVisual(self)) {
			game.removeVisual(self)
		}
	}

	method image() = images

	method avanza() {
		if (game.height() > self.position().y().abs()) {
			position = self.position().down(0.5)
			self.colision()
		} else {
			game.removeTickEvent('asteroid')
		}
	}

	method aparece() {
		const x = (0 .. game.width() - 2).anyOne()
		const y = game.height() - 1
		position = game.at(x, y)
		game.addVisual(self)
		game.onTick(100, 'asteroid', { self.avanza()})
	}

}

class Bala {

	var property position

	method impactoBalaEnemiga(bala) {}

	method impactoAsteroide() {}

	method impactoBalaNave(param) {}

	method image()

	method destruiObjetos(objetos)

	method desaparece() {
		if (game.hasVisual(self)) {
			game.removeVisual(self)
		}
	}

	method avanza(hacia, evento) {
		if (game.height() > self.position().y().abs()) {
			position = hacia
			self.colision()
		} else {
			game.removeTickEvent(evento)
		}
	}

	method colision() {
		if (game.hasVisual(self)) {
			self.destruiObjetos(game.colliders(self))
		}
	}

}

class BalaNave inherits Bala {

	override method image() = "lasery.png"

	override method destruiObjetos(objetos) {
		objetos.forEach{ e => e.impactoBalaNave(self)}
	}

	method disparar() {
		position = nave.position().up(1)
		game.addVisual(self)
		game.onTick(20, 'disparoNave', { self.avanza(self.position().up(1), 'disparoNave')})
	}

}

class BalaEnemiga inherits Bala {

	override method image() = "laser_enemy.png"

	override method destruiObjetos(objetos) {
		objetos.forEach{ e => e.impactoBalaEnemiga(self)}
	}

	method disparar(desdeNaveEnemiga) {
		self.position(desdeNaveEnemiga.position())
		game.addVisual(self)
		game.onTick(20, 'disparoEnemigo', { self.avanza(self.position().down(1), 'disparoEnemigo')})
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
		game.onTick(1000, 'generarAsteroides', { new Asteroides().aparece()})
		game.onTick(5000, 'generarEnemigo', { self.generarNuevoEnemigo()})
		const naveEnemiga = new Enemigo()
		naveEnemiga.config()
	}

	method matarEnemigo() {
		self.enemigosVivos(self.enemigosVivos() - 1)
	}

	method generarNuevoEnemigo() {
		if (enemigosVivos < 2) {
			new Enemigo().config()
			enemigosVivos += 1
		}
	}

	method gameOver() {
		game.clear()
		game.addVisual(gameOver)
		self.enemigosVivos(1)
		keyboard.enter().onPressDo{ self.configurate()}
	}

}

object gameOver {

	method image() = 'gameOver.png'

	method position() = game.at(5, 7)

}

object nave {

	var property vida
	var property position = game.center()

	method image() = "nave.png"

	method impactoBalaEnemiga(bala) {
		self.actualizarVida(80)
		bala.desaparece()
	}

	method impactoAsteroide() {
		self.actualizarVida(30)
	}

	method impactoBalaNave(bala) {}

	method nuevoDisparo() {
		new BalaNave().disparar()
	}

	method controles() {
		keyboard.space().onPressDo{ self.nuevoDisparo()}
	}

	method actualizarVida(cantidad) {
		vida = vida - cantidad
		if (vida > 0) {
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

	method impactoBalaEnemiga(bala) {}

	method impactoAsteroide() {}

	method impactoBalaNave(bala) {
		self.actualizarVida()
		bala.desaparece()
	}

	method actualizarVida() {
		vida -= 80
		if (vida > 0) {
			game.say(self, 'vida: ' + self.vida().toString())
		} else {
			game.removeVisual(self)
			juego.matarEnemigo()
		}
	}

	method generarEnemigo() {
		self.generarCoordenada()
		self.puedoAparecerEn(position)
	}

	method config() {
		game.onTick(800, 'disparar', { self.nuevoDisparo()})
		game.onTick(1000, 'movete', { self.cambiaPosicion()})
		self.generarEnemigo()
	}

	method generarCoordenada() {
		const x = (0 .. game.width() - 2).anyOne()
		const y = game.height() - 3
		position = game.at(x, y)
	}

	method puedoAparecerEn(posicion) {
		if (game.getObjectsIn(posicion).size() == 0) {
			game.addVisual(self)
		} else {
			self.generarEnemigo()
		}
	}

	method cambiaPosicion() {
		if (nave.position().x() > self.position().x()) {
			if (self.puedoMoverme(position.right(2))) {
				self.position(position.right(1))
			}
		}
		if (nave.position().x() < self.position().x()) {
			if (self.puedoMoverme(position.left(2))) {
				self.position(position.left(1))
			}
		}
	}

	method puedoMoverme(direccion) {
		return game.getObjectsIn(direccion).size() == 0
	}

	method nuevoDisparo() {
		if (game.hasVisual(self)) {
			new BalaEnemiga().disparar(self)
		}
	}

}

