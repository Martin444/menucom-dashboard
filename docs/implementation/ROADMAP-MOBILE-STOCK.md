# Roadmap: Aplicación Móvil para Control de Stock y Reponedores

## Estado Actual (MVP Dashboard Web)
Actualmente, el sistema principal (`menucom-dashboard`) está optimizado para la creación rápida de productos y la gestión del catálogo visual.
En la vista `create_ward_item_page.dart` los únicos campos obligatorios que estamos solicitando para la creación de un nuevo producto son:
- Foto
- Nombre
- Precio
- Descripción

El modelo de datos del backend (`CatalogItemModel`) **ya está preparado** para una gestión de inventario y lógicas promocionales avanzadas, pero dichos valores están siendo insertados por defecto o nulos desde la web para simplificar la interfaz. Campos soportados actualmente por la API pero inactivos en la UI web:
- `quantity` (Stock numérico - por defecto en 0)
- `sku` (Código de barras o referencia alfanumérica)
- `discountPrice` (Precio con descuento)
- `category` y `tags` 

## Visión para la MVP de la App Móvil (Reponedores / Control de Stock)
En el roadmap futuro, construiremos una aplicación móvil complementaria diseñada específicamente para operarios de inventario y "reponedores".

### Funcionalidades Clave Proyectadas
1. **Escáner de Código de Barras (Barcode/QR Scanner)**: 
   - Utilizaremos el hardware de la cámara del dispositivo móvil para escanear de forma nativa los códigos de los productos, agilizando el flujo logístico a través de librerías en Flutter como `mobile_scanner`.
   - El código escaneado se mapeará directamente a la propiedad `sku` definida en el `CatalogItemModel`.
   
2. **Alta Rápida de Inventario**:
   - Al escanear un SKU no registrado, el usuario solo tendrá que tomarle la foto y ponerle un nombre para crearlo en base de datos de manera exprés.

3. **Actualización de Cantidades en Tiempo Real**:
   - Al escanear un SKU de un producto existente, la app ofrecerá interactividad tipo "+ / -" para modificar o sobreescribir la propiedad `quantity` enviándolo al backend para su almacenamiento.

## Tareas Técnicas Futuras a Implementar
- [ ] **Validar Params de la API_CLIENT**: Revisar que `CreateCatalogItemParams` y `UpdateCatalogItemParams` del paquete `menu_dart_api` incluyan los mapeos explícitos para enviar la propiedad `quantity` y `sku` a nuestro servidor centralizado en los casos de uso.
- [ ] **Desarrollo UI/UX Móvil**: Crear un prototipo rápido priorizando "one-hand use" para que el operario del comercio pueda tomar inventario usando la cámara de forma ininterrumpida.
- [ ] **Endpoints**: Desarrollar en el framework back-end (si no existe) un buscador en reversa `findBySku(catalogId, sku)` como función optimizada en la capa de datos.
