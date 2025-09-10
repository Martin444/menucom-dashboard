# 🔧 Scripts de Configuración

## sync_configs.dart

### 📋 Propósito
Script automatizado para sincronizar las configuraciones entre `.vscode/launch.json` y `netlify.toml`, asegurando que todas las variables de entorno estén alineadas entre desarrollo y despliegue.

### 🚀 Uso
```bash
# Ejecutar desde la raíz del proyecto
dart scripts/sync_configs.dart
```

### ⚙️ Funcionalidad
1. **Lee** las configuraciones de `.vscode/launch.json`
2. **Extrae** todas las variables `--dart-define` de la configuración QA
3. **Genera** comandos de build para diferentes contextos:
   - QA/Preview: API de Heroku
   - Producción: API de DigitalOcean
4. **Actualiza** `netlify.toml` con las configuraciones sincronizadas

### 📋 Variables Sincronizadas
- ✅ `API_URL` (diferente por entorno)
- ✅ `FIREBASE_*` (idénticas en todos los entornos)
- ✅ `GOOGLE_SIGN_IN_*` (idénticas en todos los entornos)
- ✅ Configuraciones adicionales

### 🔍 Validaciones
- Verifica que `.vscode/launch.json` exista
- Maneja comentarios JSON-C
- Extrae solo variables válidas `--dart-define`

### 📝 Output
El script genera un `netlify.toml` con:
- Comando de build por defecto (QA)
- Comando de build para producción
- Variables de entorno documentadas
- Headers de seguridad configurados
- Redirects para SPA

### 🚨 Cuándo Ejecutar
- Después de agregar nuevas variables en `launch.json`
- Antes de hacer push a ramas que se despliegan
- Cuando se actualicen endpoints de API
- Al cambiar configuraciones de Firebase/Google

### 🧪 Testing
Para probar el script:
```bash
# Crear backup del netlify.toml actual
cp netlify.toml netlify.toml.backup

# Ejecutar script
dart scripts/sync_configs.dart

# Verificar cambios
git diff netlify.toml

# Restaurar si es necesario
cp netlify.toml.backup netlify.toml
```

---

**Nota**: Este script mantiene la sincronización automática y reduce errores manuales en la configuración de despliegue.
