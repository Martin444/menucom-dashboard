# 📦 Documentación: Tabla de Órdenes (OrdersTable)

## 📝 Descripción General
La tabla de órdenes es el componente principal para la gestión de pedidos en el dashboard. Permite visualizar de forma estructurada toda la información relevante de los pedidos realizados por los clientes.

---

## 🚀 Mejoras Recientes

### 1. Columna de Acciones
Se ha implementado una nueva columna de **Acciones** para mejorar la interactividad de la tabla.
- **Botón "Ver Detalle"**: Permite abrir un diálogo modal con la información completa de la orden sin cambiar de página.
- **Diseño**: Uso de iconos descriptivos (`visibility_outlined`) con colores temáticos de la marca.

### 2. Corrección en Cálculo de Ingresos
Se ajustó la lógica de negocio en el widget de métricas asociado (`OrdersMetricsWidget`):
- **Antes**: Se sumaban todas las órdenes (incluyendo canceladas y pendientes).
- **Ahora**: El "Total Income" solo suma órdenes en estado **"Confirmado" (En curso)** o **"Finalizado" (Completado)**, proporcionando una métrica financiera real.

### 3. Vista de Detalle (Modal)
Se implementó una visualización rápida que incluye:
- Información del cliente.
- Estado actual.
- Desglose de productos (nombre, cantidad y precio unitario).
- Total de la orden.

---

## 🛠️ Arquitectura Técnica

### Componentes Involucrados
1. **`OrdersTable` (`pu_material`)**: Organismo reutilizable que define la estructura de la tabla y los headers.
2. **`AdminDataTableMolecule`**: Base estructural de la tabla con soporte para scroll horizontal y responsive.
3. **`OrdersPage`**: Implementa la lógica de los callbacks (ej. navegación o apertura de diálogos).
4. **`OrdersController`**: Gestiona el estado de los datos y el mapeo de estados del API al UI.

### Modelos de Datos
- **`Order`**: Representa la entidad principal del pedido.
- **`OrderItem`**: Representa cada producto dentro de una orden.

---

## 🔮 Desarrollos Futuros Propuestos

### 1. Acciones Rápidas de Estado
Añadir botones en la columna de acciones para cambiar el estado de una orden (ej. de "Pendiente" a "En curso") con un solo clic, sin entrar al detalle.

### 2. Filtros Avanzados y Búsqueda
- Búsqueda por nombre de cliente o número de orden.
- Filtros por rango de fechas.
- Filtros por método de pago.

### 3. Exportación de Datos
Añadir funcionalidad para exportar la lista de órdenes filtradas a formatos **CSV** o **PDF** para reportes externos.

### 4. Acciones Masivas (Bulk Actions)
Permitir la selección de múltiples filas para realizar acciones conjuntas, como marcar varias órdenes como completadas o eliminarlas.

### 5. Actualizaciones en Tiempo Real
Integración con WebSockets o Firebase Cloud Messaging (FCM) para que la tabla se actualice automáticamente cuando entre un nuevo pedido, sin necesidad de recargar la página.

---

> [!NOTE]
> Esta documentación debe actualizarse cada vez que se realice un cambio significativo en la estructura o lógica de la tabla de órdenes.
