<incluir archivo="Header">
<incluir archivo="Menu">
<div class="container">
	<h3>Punto de venta</h3>

  <div class="row">
    <div class="col-md-6">
      <label>Cliente</label>
    	<select id="cliente" name="cliente" class="form-control">
        <ciclo clientes>
          <option value="{cliente}">{razonSocial}</option>
        </ciclo clientes>
      </select>
    </div>
    <div class="col-md-6">
      <div class="alert alert-info" role="alert">Total: <span class="glyphicon glyphicon-usd" aria-hidden="true"></span><span id="totalVenta">0.00</span></div>
    </div>
  </div>

  <input type="hidden" id="vendedor" name="vendedor" class="form-control" value="{vendedor}">
  <input type="hidden" id="estatus" name="estatus" class="form-control" value="Pago"><br>
  <input type="hidden" value="{ivaPorcentaje}" id="ivaPorcentaje">
  <input type="hidden" value="{iepsPorcentaje}" id="iepsPorcentaje">

  <div class="row">
    <div class="col-sm-6">
      <label>Captura / Escanea el producto</label>
      <input type="text" id="claveProducto" name="claveProducto" class="form-control" value="">
    </div>
    <div class="col-sm-6">
      <p><a class="btn btn-primary btn-lg" href="#" onclick="guardar()" role="button">Cobrar</a></p>
    </div>
  </div>

  <br>
  <div id="errores"></div>
	<div id="gridVenta" class="handsontable"></div>

</div>

<div id="myModal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 id="titulo" class="modal-title">Pago</h4>
            </div>
            <div class="modal-body">
              <label>Total a pagar</label>
              <input type="text" id="total" class="form-control" disabled="true">
              <label>En efectivo</label>
              <input type="text" name="efectivo" id="efectivo" class="form-control">
              <label>Con tarjeta</label>
              <input type="text" name="tarjeta" id="tarjeta" class="form-control">
              <label>Con monedero electrónico</label>
              <input type="text" name="monedero" id="monedero" class="form-control">
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
  $("#claveProducto").keypress(function(event) {
    if(event.which == 13) {
      if(hot.getDataAtCell(hot.countRows()-2,1) == 'NO EXISTE')
        hot.setDataAtCell(hot.countRows()-2,0,$(this).val())
      else
        hot.setDataAtCell(hot.countRows()-1,0,$(this).val())
      $(this).val('')
      $(this).focus()
    }
  })
})

$("#claveProducto").focus()

var
data = [],
grid = document.getElementById('gridVenta'),
hot;

hot = new Handsontable(grid, {
  data: data,
  minSpareRows: 1,
  colHeaders: true,
  rowHeaders: true,
  fixedRowsTop: 0,
  startCols: 4,
  colHeaders: ['Clave', 'Descripcion', 'Unidad', 'Precio', 'Cantidad', 'IVA', 'IEPS', 'Subtotal', 'Grava IVA', 'Grava IEPS', 'Producto'],
  columns: [
    {data:'clave'},
    {data:'descripcionCorta',readOnly: true},
    {data:'unidad', readOnly: true},
    {data:'precio', type: 'numeric', format: '0,0.00', language: 'en', readOnly: true},
    {data:'cantidad', type: 'numeric', format: '0,0.00', language: 'en'},
    {data:'iva', type: 'numeric', format: '0,0.00', language: 'en', readOnly: true},
    {data:'ieps', type: 'numeric', format: '0,0.00', language: 'en', readOnly: true},
    {data:'subtotal', type: 'numeric', format: '0,0.00', language: 'en', readOnly: true},
    {data:'gravaIVA', readOnly: true},
    {data:'gravaIEPS', readOnly: true},
    {data:'producto', readOnly: true},
  ], 
  contextMenu: true,
  afterChange: function (changes, source) {
    if ((source == 'edit' || source == 'paste')) {
      if(changes[0][1] == "clave") {
        sincco.consumirAPI('POST','{BASE_URL}productos/apiClave', {clave: changes[0][3]})
        .done(function(data) {
          if(data.respuesta.length) {
            $("#errores").html('')
            hot.setDataAtCell(changes[0][0],1,data.respuesta[0].descripcionCorta)
            hot.setDataAtCell(changes[0][0],2,data.respuesta[0].unidadMedida)
            hot.setDataAtCell(changes[0][0],3,data.respuesta[0].precio)
            hot.setDataAtCell(changes[0][0],8,data.respuesta[0].iva)
            hot.setDataAtCell(changes[0][0],9,data.respuesta[0].ieps)
            hot.setDataAtCell(changes[0][0],10,data.respuesta[0].producto)
            hot.setDataAtCell(changes[0][0],4,1)
          } else {
            hot.setDataAtCell(changes[0][0],1,'NO EXISTE')
          }
        }).fail(function(jqXHR, textStatus, errorThrown) {
          console.log(errorThrown)
        })
      }
      if(changes[0][1] == "cantidad") {
        var subtotal = parseFloat(hot.getDataAtCell(changes[0][0],4))*parseFloat(hot.getDataAtCell(changes[0][0],3))
        var iva = parseInt(hot.getDataAtCell(changes[0][0],8)) * (parseInt($("#ivaPorcentaje").val())/100)
        iva = subtotal * iva
        ieps = subtotal * ieps
        var ieps = parseInt(hot.getDataAtCell(changes[0][0],9)) * (parseInt($("#iepsPorcentaje").val())/100)
        hot.setDataAtCell(changes[0][0],5, iva)
        hot.setDataAtCell(changes[0][0],6, ieps)
        hot.setDataAtCell(changes[0][0],7, subtotal + iva + ieps)
      }
      $('#gridVenta td:nth-child(10),th:nth-child(10)').hide()
      $('#gridVenta td:nth-child(11),th:nth-child(11)').hide()
      $('#gridVenta td:nth-child(12),th:nth-child(12)').hide()
      actualizaTotal()
    }
  }
})

function actualizaTotal() {
  var totalVenta = 0
  hot.getData().forEach(function(element, index, array) {
    if(!isNaN(parseFloat(element.subtotal))) {
      totalVenta = totalVenta + parseFloat(element.subtotal)
    }
  })
  $("#totalVenta").html(totalVenta)
  $("#total").val(totalVenta)
  $("#efectivo").val(totalVenta)
  $("#tarjeta").val('0.00')
  $("#monedero").val('0.00')
  return true
}

function guardar() {
  $('#myModal').modal('show')

  /*
  sincco.consumirAPI('POST','{BASE_URL}ventas/apiPost', {cliente: $("[name='cliente']").val(), vendedor: $("[name='vendedor']").val(), estatus: $("[name='estatus']").val(), productos: hot.getData()} )
  .done(function(data) {
    if(data.respuesta.venta)
      window.location = '{BASE_URL}ventas'
    else
       $("#errores").html('<div class="alert alert-warning" role="alert"><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>Hubo un error al guardar los datos, intenta de nuevo</div>')
  }).fail(function(jqXHR, textStatus, errorThrown) {
    console.log(errorThrown)
  })
  */
}
</script>

<incluir archivo="Footer">