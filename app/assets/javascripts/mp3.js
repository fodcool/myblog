//$(document).on('ready, page:change',function(){
$(document).ready(function(){
  $('.header-circle').click(function(){
    if($('.start-misic').offset().left == 0){
      $('.audio-tag')[0].pause();
      $('.stop-misic').hide();
      $('.start-misic').show();
      console.info("stop")
    }else{
      $('.audio-tag')[0].play();
      $('.start-misic').hide();
      $('.stop-misic').show();
      console.info("start")
    }
  })
  $('.audio-tag')[0].onended = function(){
    $('.stop-misic').hide();
    $('.start-misic').show();
    console.info("===end")
  }
});
