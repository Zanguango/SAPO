# Checklist de seguridad y privacidad — S.A.P.O.

## 1. Naturaleza y límites del prototipo

- [x] El proyecto se define como prototipo académico para un escenario simulado.
- [x] Se establece el uso exclusivo de datos ficticios.
- [x] Se excluyen conexiones con sistemas policiales, judiciales o administrativos reales.
- [x] Se documenta que no es un sistema de producción ni debe desplegarse como tal.

## 2. Identidad y acceso

- [x] El modelo global contempla tres perfiles base protegidos: `ADMINISTRADOR`, `SUPERVISOR` y `AGENTE`.
- [x] La implementación práctica exige como mínimo dos perfiles de prueba con permisos diferenciados; la selección concreta de esos dos perfiles se fijará al planificar SAPO-005.
- [x] La arquitectura prevé autenticación en el backend.
- [x] La autorización se comprobará en el servidor para cada operación protegida.
- [ ] Implementar el almacenamiento seguro de contraseñas mediante hash adecuado cuando se construya el backend.
- [ ] Implementar comprobaciones de autenticación, expiración y revocación de sesión según el mecanismo seleccionado.

## 3. Validación y persistencia

- [x] La arquitectura separa controladores, servicios y repositorios.
- [x] Las entradas deberán validarse en el servidor antes de ejecutar operaciones.
- [x] Las consultas a PostgreSQL deberán utilizar parámetros, no concatenación directa de entradas.
- [ ] Implementar y probar las validaciones de los endpoints cuando exista el backend.
- [ ] Probar restricciones, claves foráneas y transacciones en los flujos funcionales.

## 4. Secretos y configuración

- [x] Se incorpora `.gitignore` para excluir archivos locales `.env` y secretos.
- [x] Se prepara `backend/.env.example` sin credenciales reales.
- [ ] Comprobar antes de cada publicación que no se hayan incluido contraseñas, tokens o secretos.
- [ ] Configurar el usuario de PostgreSQL de la aplicación con los privilegios mínimos necesarios cuando se conecte el backend.

## 5. Auditoría mínima, errores y registros

- [x] El incremento práctico contempla auditoría mínima de las acciones relevantes de las operaciones implementadas.
- [x] La consulta de auditoría se limitará a perfiles autorizados.
- [x] Los eventos no deben incluir contraseñas, tokens, secretos ni datos sensibles innecesarios.
- [x] La arquitectura establece que los errores se tratarán en el backend.
- [ ] Evitar exponer trazas, consultas SQL, contraseñas o configuración interna en las respuestas de la API.
- [ ] Evitar registrar credenciales, tokens o datos de autenticación en logs.
- [ ] Añadir pruebas para solicitudes inválidas y accesos no autorizados.
- [ ] Verificar la creación de eventos de auditoría y los permisos de consulta del histórico.

## 6. Datos ficticios y demostración

- [x] Los datos de prueba deberán ser inventados y no corresponder a personas reales.
- [x] Los scripts de carga se mantendrán separados del esquema.
- [x] Se documenta la necesidad de proporcionar registros de entidades vinculadas antes de ejecutar determinadas operaciones.
- [ ] Revisar los datos de demostración antes de grabar el vídeo o publicar capturas para evitar exposición accidental de datos no ficticios.

## 7. Copias y restauración

- [x] La asignatura exige contemplar y describir el mecanismo de backup.
- [x] La propuesta incluye una prueba de restauración de PostgreSQL en una instancia de prueba durante la fase de validación.
- [ ] Ejecutar y documentar una copia y restauración en una base aislada, verificando recuentos y relaciones.

## 8. Alcance de esta checklist

Las casillas marcadas reflejan decisiones de diseño y controles documentados; no significan que las medidas técnicas estén implementadas. La auditoría mínima de las operaciones comprometidas y la verificación básica de backup/restauración sí forman parte del alcance del prototipo. La auditoría avanzada de todo el producto, la gestión completa de usuarios/perfiles y las políticas empresariales de backup quedan fuera del incremento práctico. La definición detallada de este alcance está en [docs/PROJECT_BASELINE.md](PROJECT_BASELINE.md).
