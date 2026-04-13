---
name: atomic-design-strict
description: "Estrictas reglas de diseño atómico para Flutter: cero funciones que retornen Widgets y un archivo único por cada clase."
---

# atomic-design-strict

Esta skill impone directrices arquitectónicas rigurosas basadas en *Atomic Design* para el desarrollo y contribución en proyectos Flutter.

## Reglas Principales (DE OBLIGATORIO CUMPLIMIENTO)

### 1. Cero Funciones que retornen Widgets
Nunca encapsules la creación de UI en funciones privadas o públicas de la forma `Widget _buildElement(...)`. 
- **Malo:** `Widget _buildHeader() { return Content(); }`
- **Bueno:** `class Header extends StatelessWidget/StatefulWidget { ... }`
Esto asegura que el frame constrúya, difiera y monte correctamente los widgets para no romper el ciclo de vida o arruinar el performace del arbol de renderizado. Además respeta los tests individuales.

### 2. Un Archivo por Clase (Single Responsibility)
Cada widget o clase debe tener su propio archivo. Queda estrictamente prohibido anidar múltiples declaraciones de clases (por ejemplo atomos, moléculas o viewmodels) dentro de un único archivo Dart.
Si se necesita abstraer una sección de una vista actual (e.g., separar el header del contenido), debes:
1. Crear un nuevo archivo Dart en la subcarpeta correspondiente (ej. `widget/mi_componente_nuevo.dart`).
2. Declarar la clase heredando de un Widget como corresponda.
3. Importarlo y usarlo en la clase padre.

### 3. Escalafón Atómico Estricto
La carpeta `widgets` o núcleo debe respetar jerarquías conceptuales:
- **Atomos:** Elementos indivisibles (Textos genéricos, Botón primario, un Input).
- **Moléculas:** Agrupamiento primitivo (Un campo con label y mensaje de error).
- **Organismos:** Secciones significativas de la app que combinan varas moléculas y átomos para formar algo que se maneje independientemente (Un Formulario con estado interno, una Header Card con acciones).
- **Templates / Layouts:** Contenedores espaciales que dicen cómo se van a organizar los Organismos.
- **Pages (Views):** Vistas completamente inyectables mediante un manejador de rutas. Único lugar donde el `Controller / ViewModel` es altamente conectado con el Layout o Context.

### 4. Aislamiento de Librería UI (`pu_material`)
Cualquier átomo, molécula, organismo genérico o componente visual reutilizable que no dependa estrechamente y de manera exclusiva de una Feature del negocio **DEBE** vivir y ser exportado desde el paquete o carpeta `pu_material/`. Con este enfoque, el proyecto base debe limitarse a consumir elementos de interfaz a través de las importaciones de `pu_material`, garantizando total desacoplamiento entre el núcleo del diseño UI/UX y la lógica del cliente/app.
