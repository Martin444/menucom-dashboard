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

## 2. Register Commerce (`register_commerce.dart`)

### Críticos
| # | Problema | Línea | Solución |
|---|----------|-------|----------|
| 1 | `GetBuilder` rebuild completo | 31 | Cambiar a `Obx()` |
| 2 | Error text复用复用 | 138,150,189 | Usar diferente error para cada campo |
| 3 | `load` compartido | 209 | Estado independiente para registro |

### Medium
| # | Problema | Línea | Solución |
|---|----------|-------|----------|
| 4 | `ScrollConfiguration` innecesario | 53 | Eliminar o justificar |
| 5 | Altura fija `size.height - 100` | 51 | Usar `constraints.maxHeight` |
| 6 | Validator no usa el valor | 115-123 | Usar `value` en validación |

### Mejoras UX
- [ ] Agregar términos y condiciones checkbox
- [ ] Progress indicator del upload de logo
- [ ] Validación de contraseña (mín 8 chars, etc)
- [ ] Confirmar contraseña (repetir)

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