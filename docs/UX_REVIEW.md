# UX/UI Code Review - Login & Registro

## Error Flutter
El error de `build\flutter_assets` es de permisos. Solución:
```
Ejecutar Flutter como administrador
O eliminar manualmente la carpeta build/
```

---

## 1. Login Page (`login_page.dart`)

### ✅ ARREGLADO - Sprint 1
| # | Problema | Solución |
|---|----------|----------|
| 1 | `GetBuilder` rebuild completo | ✅ Cambiado a `Obx()` en línea 28 |
| 2 | Null safety inconsistente | ✅ `errorTextEmail` ahora `RxString` (no nullable) |
| 3 | `load` compartido entre botones | ✅ Agregado `isLoggingGoogle` separado |

### Pendientes
| # | Problema | Línea | Solución |
|---|----------|-------|----------|
| 4 | Spacing arbitrario (80,30,15,10,60) | Varios | Crear constantes spacing |
| 5 | Hero tag sin destino | 55 | Usar o remover tag |
| 6 | Logo muy grande en móvil (90px) | 58 | Hacer responsive |

### Mejoras UX
- [ ] Agregar "Recordarme" checkbox
- [ ] Validación de email en tiempo real
- [ ] Links a Términos y Condiciones
- [ ] Mostrar/ocultar contraseña (el toggle existe pero no se usa)

---

## 3. Home Page (`home_page.dart`)

### ✅ ARREGLADO - Sprint 2
| # | Problema | Solución |
|---|----------|----------|
| 1 | Variables NO reactivas | ✅ `isLoaginDataUser` y `everyListEmpty` ahora `RxBool` |
| 2 | GetBuilder sin Obx | ✅ Agregado `Obx()` para rebuilds mínimos |
| 3 | Múltiples `update()` innecesarios | ✅ Eliminados, RxBool ya notifica |

### Pendientes
| # | Problema | Línea | Solución |
|---|----------|-------|----------|
| 4 | `debugPrint` en producción | múltiples | Remover o conditional |

### Mejoras UX
- [ ] Skeleton loading en vez de spinner
- [ ] Pull-to-refresh
- [ ] Animaciones de transición entre roles

---

##共通 (Ambos)
- [ ] Aplicar spacing consistente
- [ ] Unificar null safety patterns
- [ ] Crear variables de loading independientes

---

## Prioridades
1. **Sprint 1**: GetBuilder → Obx, loading states separados
2. **Sprint 2**: Error texts específicos por campo
3. **Sprint 3**: UX improvements (T&C, recordarme, etc)