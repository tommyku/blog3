(()=>
  class FourOhFourPage
    constructor: (id)->
      @dom = document.getElementById(id)
      @path = window.location.pathname

    o_0: ->
      return @showBonus('#admin') if @path.match(/admin|login|signin/)
      return @showBonus('#logout') if @path.match(/logout|signout/)
      return @showBonus('#about') if @path.match(/about|who|contact/)
      return @showBonus('#curse') if @path.match(/wtf|fuck|shit|omg|yeah|abc|123|asasas|yo/)
      return @showBonus('#error') if @path.match(/error/)
      @showBonus('#default')

    showBonus: (id)->
      item = @dom.querySelectorAll(id)[0]
      return unless item
      item.classList.remove('hidden')


  fourOhFour = new FourOhFourPage('bonus')
  fourOhFour.o_0()
)()
