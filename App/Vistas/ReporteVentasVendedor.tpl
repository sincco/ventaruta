<incluir archivo="Header">
<incluir archivo="Menu">
<div class="container">
  <h3>Reporte de ventas por vendedor</h3>
  <div class="row">
    <form id="filtro">
      <div class="input-group input-daterange">
        <span class="input-group-addon">desde</span>
        <input type="text" class="form-control" value="" id="desde" data-date-format="yyyy-mm-dd">
        <span class="input-group-addon">hasta</span>
        <input type="text" class="form-control" value="" id="hasta" data-date-format="yyyy-mm-dd">
      </div>
      <label>Vendedor</label>
        <select id="vendedor" name="vendedor" class="form-control">
          <ciclo vendedores>
            <option value="{vendedor}">{nombre}</option>
          </ciclo vendedores>
        </select>
    </form>
  </div>
  <br>
  <p><a class="btn btn-primary btn-md" href="#" role="button" onclick="genera()"><span class="glyphicon glyphicon-print" aria-hidden="true"></span> Generar</a></p>
  <div class="row">
    <table id="reporte" data-mobile-responsive="true" data-show-export="true" data-page-size="25" data-pagination="true" data-show-pagination-switch="true"></table>
  </div>
</div>
<script type="text/javascript">
function genera() {
  sincco.consumirAPI('POST','{BASE_URL}reportes/ventasvendedor/accion/csv/desde/' + $("#desde").val() + '/hasta/' + $("#hasta").val() + '/vendedor/' + $("#vendedor").val())
  .done(function(respuesta) {
    $("#reporte").bootstrapTable('destroy') 
    $('#reporte').bootstrapTable({
      columns:[
        {field:'fecha',title:'Fecha',sortable:true, visible:true},
        {field:'nombre',title:'Vendedor',sortable:false, visible:true},
        {field:'venta',title:'Venta',sortable:false, visible:true},
        {field:'gasto',title:'Gasto',sortable:false, visible:true},
        {field:'costo',title:'Costo',sortable:false, visible:true}
      ],
      data:respuesta.respuesta
    }).fail(function(jqXHR, textStatus, errorThrown) {
      console.log(errorThrown)
    })
  })
  /*
  console.log('generar')
  $("#frame").attr('src','{BASE_URL}reportes/utilidades/accion/csv/desde/' + $("#desde").val() + '/hasta/' + $("#hasta").val())
  */
}
$('.input-daterange input').each(function() {
    $(this).datepicker("clearDates");
});
</script>
<incluir archivo="Footer">