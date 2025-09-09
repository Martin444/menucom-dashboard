# 🚀 Configuración de Despliegue y Desarrollo Sincronizada

## 📋 Resumen de Configuraciones

Este documento describe cómo están sincronizadas las configuraciones entre el entorno de desarrollo (VS Code) y el despliegue automático en Netlify.

## 🔧 Archivos de Configuración

### 1. **`.vscode/launch.json`** - Configuraciones de Desarrollo
Contiene tres entornos de desarrollo:
- **`menucom_dev`**: Desarrollo local con API en `localhost:3001`
- **`qa_menucom`**: QA/Testing con API en Heroku
- **`menucom_beta`**: Beta/Staging con API en DigitalOcean

### 2. **`netlify.toml`** - Configuración de Despliegue
Configurado para auto-despliegue con múltiples contextos:
- **`build`**: Configuración por defecto (QA)
- **`context.production`**: Rama principal (DigitalOcean)
- **`context.deploy-preview`**: Preview de PRs (Heroku)

## 🌐 Variables de Entorno Sincronizadas

### **Variables de API**
| Variable | Desarrollo | QA/Preview | Producción |
|----------|------------|------------|------------|
| `API_URL` | `localhost:3001` | `menucom-api-60e608ae2f99.herokuapp.com` | `hammerhead-app-pouq5.ondigitalocean.app` |

### **Variables de Firebase** (Idénticas en todos los entornos)
```bash
FIREBASE_API_KEY=AIzaSyAEWpBCNon00zwt1eWfqSDiYMhH0xxLMwk
FIREBASE_AUTH_DOMAIN=menucom-ff087.firebaseapp.com
FIREBASE_PROJECT_ID=menucom-ff087
FIREBASE_STORAGE_BUCKET=menucom-ff087.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=1053737382833
FIREBASE_APP_ID_WEB=1:1053737382833:web:d4173f40d6b88a52900390
FIREBASE_MEASUREMENT_ID=G-D5ZC2VB6GR
```

### **Variables de Google Sign-In** (Idénticas en todos los entornos)
```bash
GOOGLE_SIGN_IN_WEB_CLIENT_ID=1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com
GOOGLE_SIGN_IN_IOS_CLIENT_ID=1053737382833-your-ios-client-id.apps.googleusercontent.com
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=1053737382833-your-android-client-id.apps.googleusercontent.com
```

### **Variables Adicionales**
```bash
FIREBASE_IOS_BUNDLE_ID=com.pickmeup.menucomdashboard
```

## 🔄 Flujo de Despliegue Automático

### **Branch-Based Deployment**
- **Rama `main`/`master`** → Producción (DigitalOcean API)
- **Otras ramas** → QA/Preview (Heroku API)
- **Pull Requests** → Deploy Preview (Heroku API)

### **Comando de Build por Contexto**
```bash
# QA/Preview (por defecto)
flutter build web --release --web-renderer html [variables QA]

# Producción
flutter build web --release --web-renderer html [variables Producción]
```

## 🛡️ Configuraciones de Seguridad

### **Headers de Seguridad**
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`

### **Content Security Policy (CSP)**
Configurado para permitir:
- ✅ Scripts de Google APIs y Accounts
- ✅ Estilos de Google Fonts
- ✅ Conexiones a APIs de backend y Firebase
- ✅ Frames de autenticación de Google

### **SPA Redirects**
Configurado redirect `/*` → `/index.html` para routing de Flutter Web.

## 🔍 Verificación de Configuraciones

### **Variables Requeridas para Google Sign-In**
Para que funcione correctamente en Netlify, estas variables DEBEN estar presentes:
- ✅ `GOOGLE_SIGN_IN_WEB_CLIENT_ID`
- ✅ `FIREBASE_API_KEY`
- ✅ `FIREBASE_AUTH_DOMAIN`
- ✅ `FIREBASE_PROJECT_ID`

### **URLs Permitidas en Google Cloud Console**
Asegúrate de que estos dominios estén autorizados:
- `https://your-netlify-domain.netlify.app`
- `https://your-custom-domain.com` (si aplica)

## 🚨 Troubleshooting

### **Error: "Invalid origin for the client"**
1. Verificar que el dominio de Netlify esté en Google Cloud Console
2. Revisar que `GOOGLE_SIGN_IN_WEB_CLIENT_ID` sea correcto
3. Confirmar que CSP permita `https://accounts.google.com`

### **Error: "Firebase configuration missing"**
1. Verificar que todas las variables `FIREBASE_*` estén en `netlify.toml`
2. Confirmar que no hay typos en los nombres de variables
3. Revisar logs de build en Netlify

### **Error de APIs no autorizadas**
1. Verificar que `API_URL` apunte al endpoint correcto
2. Confirmar CORS configurado en el backend
3. Revisar que CSP permita conexiones al backend

## 📝 Mantenimiento

### **Cuando agregar nueva variable:**
1. ✅ Agregar a `.vscode/launch.json` (todos los entornos)
2. ✅ Agregar a `netlify.toml` (todos los contextos)
3. ✅ Documentar en este archivo
4. ✅ Probar en deploy preview antes de merge

### **Cuando cambiar API endpoint:**
1. ✅ Actualizar en `launch.json` según entorno
2. ✅ Actualizar en `netlify.toml` según contexto
3. ✅ Verificar CORS en el nuevo endpoint
4. ✅ Probar autenticación social

---

**Nota**: Esta configuración asegura que el Google Sign-In y Firebase funcionen correctamente tanto en desarrollo como en producción, manteniendo sincronizadas todas las variables de entorno entre VS Code y Netlify.
