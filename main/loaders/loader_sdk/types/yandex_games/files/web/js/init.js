window.history.pushState({name: "start"}, "");

// Перехватываем кнопку Back на пульте 
window.onpopstate = function(event) {
   //Внутри этих скобок любой свой код
   JsToDef.send("KeyPressed", {
      type: "back"
   })

   window.history.pushState({name: "start"}, "");
   //Внутри этих скобок любой свой код

   
   event.preventDefault();
};
