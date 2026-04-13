---
name: responsive-design-pro
description: Reglas estrictas para el diseño adaptativo en Flutter. 3 Breakpoints, escalado relativo y flexibilidad de Layout.
---
# Responsive Design Pro

Al activar esta skill, todos los widgets de UI generados en Flutter respetarán las siguientes directrices de diseño resposivo:

## 1. Adaptabilidad Nativa
Todo widget que pueda variar de tamaño debe estar envuelto o utilizar internamente medidas basadas en contexto.
- Preferir el uso de `LayoutBuilder` para componentes aislados.
- Usar extensiones de `MediaQuery` para el layout general de la pantalla.

## 2. Breakpoints Estrictos
El diseño responderá a 3 puntos de quiebre principales:
- **Mobile**: `< 600px` (Diseño apilado, navegación inferior o cajón).
- **Tablet**: `600px - 1024px` (Uso de grillas moderadas, menús laterales colapsables).
- **Desktop**: `> 1024px` (Multicolumna, menús expandidos).

## 3. Flexibilidad Geométrica
Para evitar el típico error de `RenderFlex overflow` al achicar las pantallas:
- **Sustituir `Row` por `Flex`**: Configurar la propiedad `direction` dinámicamente (`Axis.horizontal` en desktop, `Axis.vertical` en mobile).
- **Uso de `Wrap`**: Si el contenido consta de chips, botones o tarjetas pequeñas, encapsularlos en un `Wrap` en lugar de una lista unidimensional pura.
- **Uso seguro de `Expanded` y `Flexible`** cuando se mantenga un eje fijo.

## 4. Escalado Relativo
Evitar anchos, altos, paddings y tamños de fuente completamente estáticos (`double` hardcodeado).
- Utilizar factores multiplicadores en base al ancho/alto de pantalla o emplear un diseño base (ej. *Figma viewport design*) escalado por porcentaje.
- Emplear fuentes escalables o clamps si es necesario.
