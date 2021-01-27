/*global $*/
$(document).on('turbolinks:load', function(){

  $('#year').on('change', function(){

    $('#month').removeAttr('disabled');

    $('#month').html('');

    var year = $(this).val();
    const user = $(this).data('user');

    console.log(year);

    if(year == ""){
      $('#month').attr('disabled', 'disabled');
    }else{
      $('#month').removeAttr('disabled');
    }

    $.ajax({
    type: 'GET',
    url: '/ajax',
    data: { year: year,
            id: user
          },
    dataType: 'json'
    })

    .done(function(datas){
      if (datas.length !== 0){
        var option;
        datas.forEach(function(data){
        option = '<option value="' + data + '">' + data + '</option>';
        $('#month').append(option);
        });
      }
    })

    .fail(function(){
      alert('月データの取得に失敗しました。再読み込みしてください。');
    });
  });
});