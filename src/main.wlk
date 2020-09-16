import wollok.game.*

class ElementosDelEspacio {

	var property position

	method destruyeEnemigo() = false

	method destruyeJugador() = false

	method destruyeAsteroide() = false

	method desaparece() {
		if (game.hasVisual(self)) {
			game.removeVisual(self)
		}
	}

}

class Asteroides inherits ElementosDelEspacio {

	const images = [ "asteroid.png", "asteroid_big1.png", "asteroid_medium3.png" ].anyOne()

	method danio() = 30

	override method destruyeJugador() = true

	method image() = images

	method avanza() {
		if (game.height() > self.position().y().abs()) {
			position = self.position().down(0.5)
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
		game.onCollideDo(self, { elemento =>
			if (elemento.destruyeAsteroide()) { // disparos del jugador 
				self.desaparece()
				elemento.desaparece()
			}
		})
	}

}

class Bala inherits ElementosDelEspacio {

	method danio() = 40

	method image()

	method avanza(hacia, evento) {
		if (game.height() > self.position().y().abs()) {
			position = hacia
		} else {
			game.removeTickEvent(evento)
		}
	}

}

class BalaNave inherits Bala {

	override method image() = "lasery.png"

	override method destruyeEnemigo() = true

	override method destruyeAsteroide() = true

	method disparar() {
		position = nave.position().up(1)
		game.addVisual(self)
		game.onTick(20, 'disparoNave', { self.avanza(self.position().up(1), 'disparoNave')})
	}

}

class BalaEnemiga inherits Bala {

	override method danio() = super() * 2

	override method image() = "laser_enemy.png"

	override method destruyeJugador() = true

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
		nave.position(game.at(6,0))
		nave.controles()
		nave.vida(600)
		game.onCollideDo(nave, { elemento =>
			if (elemento.destruyeJugador()) { // asteroides y disparos enemigos
				nave.actualizarVida(elemento.danio())
				elemento.desaparece()
			}
		})
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

object nave inherits ElementosDelEspacio {

	var property vida

	method image() = "nave.png"

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

class Enemigo inherits ElementosDelEspacio {

	var property vida = 300

	method image() = "enemy.png"

	method estaMasALaDerechaQue(elemento) = elemento.position().x() > self.position().x()

	method estoyApuntandoA(elemento) = elemento.position().x() == self.position().x()

	method puedoMoverme(direccion) = game.getObjectsIn(direccion).size() == 0

	method actualizarVida(cantidad) {
		vida -= cantidad
		if (vida > 0) {
			game.say(self, 'vida: ' + self.vida().toString())
		} else {
			self.desaparece()
			juego.matarEnemigo()
		}
	}

	method config() {
		self.generarEnemigo()
		game.onTick(800, 'disparar', { self.nuevoDisparo()})
		game.onTick(1000, 'movete', { if (!self.estoyApuntandoA(nave)) {
				self.cambiaPosicion()
			}
		})
		game.onCollideDo(self, { elemento =>
			if (elemento.destruyeEnemigo()) { // disparos del jugador
				self.actualizarVida(elemento.danio())
				elemento.desaparece()
			}
		})
	}

	method generarEnemigo() {
		self.generarCoordenada()
		self.puedoAparecerEn(position)
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

	method moverseHacia(posiciones) {
		if (self.puedoMoverme(position.right(2 * posiciones))) {
			self.position(position.right(posiciones))
		}
	}

	method cambiaPosicion() {
		self.moverseHacia(if (self.estaMasALaDerechaQue(nave)) {
			1
		} else {
			-1
		})
	}

	method nuevoDisparo() {
		if (game.hasVisual(self)) {
			new BalaEnemiga().disparar(self)
		}
	}

}

