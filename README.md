# S.A.P.O. — Sistema Avanzado Policial Operativo

Prototipo académico de la asignatura **Proyecto de Ingeniería de Software (47GIIN), VIU**.

S.A.P.O. modela un escenario simulado de registro y consulta de incidencias asociadas a personas ficticias. Utiliza exclusivamente datos ficticios y no se conecta con sistemas policiales, judiciales ni administrativos reales. No es un producto de producción.

## Documentación y seguimiento

- [Línea base y decisiones del proyecto](docs/PROJECT_BASELINE.md)
- [Product Backlog](docs/PRODUCT_BACKLOG.md)
- [Planificación Sprint 1](docs/SPRINT_1_PLAN.md)
- [Arquitectura de la solución](docs/ARCHITECTURE.md)
- [Estructura del proyecto](docs/PROJECT_STRUCTURE.md)
- [Entorno de desarrollo](docs/ENVIRONMENT.md)
- [Estrategia de datos iniciales ficticios](database/seeds/README.md)
- [Diagnóstico de esquema local (solo lectura)](database/diagnostics/AUDITAR_ESQUEMA_LOCAL_SOLO_LECTURA.sql)
- [Verificación de copia restaurada (solo lectura)](database/diagnostics/VERIFICAR_COPIA_RESTAURADA_SAPO_SOLO_LECTURA.sql)
- [Procedimiento de migración controlada de sapo_db](docs/MIGRACION_CONTROLADA_SAPO_DB.md)
- [Registro de trabajo del Sprint 1](docs/SPRINT_1_WORKLOG.md)
- [Diseño de la base de datos — referencia documental única](docs/DATABASE_DESIGN.md)
- [Checklist de seguridad y privacidad](docs/SECURITY_CHECKLIST.md)
- [Tablero GitHub Projects](https://github.com/users/Zanguango/projects/1)

## Alcance del incremento práctico

El incremento académico, aproximadamente el 20 % del producto, incluye el circuito personas–incidencias, autenticación y permisos básicos, CRUD mínimo de datos generales de la organización, proceso automático de seguimiento sin duplicados, dos reportes, una estadística, auditoría mínima, pruebas y verificación básica de copia/restauración. Algunas funcionalidades se implementarán en sprints posteriores; eso no las convierte en alcance futuro fuera de la asignatura. La matriz completa está en [docs/PROJECT_BASELINE.md](docs/PROJECT_BASELINE.md).

## Tecnologías previstas

- Backend: JavaScript, Node.js y Express (API REST).
- Frontend: HTML, CSS y JavaScript.
- Base de datos: PostgreSQL.
- Arquitectura: cliente-servidor por capas.

## Estructura inicial

- `backend/src`: configuración, controladores, middleware, repositorios, rutas y servicios de la futura API.
- `frontend`: recursos CSS y JavaScript de la interfaz web.
- `database/schema`: contiene `SAPO_SCHEMA.sql`, esquema canónico validado desde una base PostgreSQL 18.7 vacía mediante GitHub Actions; todavía no se ha aplicado a `sapo_db`.
- `database/seeds`: estrategia documentada; los scripts de carga todavía no están implementados.
- `tests`: pruebas unitarias y de integración.
- `docs`: backlog, planificación y documentación técnica.

La estructura es preparatoria: las carpetas no implican que las capas o funcionalidades estén implementadas.

## Estado (26/11/2026)

Las historias SAPO-001, SAPO-003, SAPO-028 y SAPO-030 del Sprint 1 aparecen cerradas como `Done` en GitHub Projects. La planificación del Sprint 1 (19–30/11/2026) fue aprobada por el profesor el 26/11/2026; el cierre formal de la iteración está previsto para el 30/11/2026.

La estructura inicial y la documentación de arquitectura, modelo de datos, entorno, seguridad y línea base de alcance están versionadas. El backend, la interfaz y la conexión Node.js/Express–PostgreSQL todavía no están implementados. Los siguientes sprints deben entregar el incremento funcional mínimo definido en la propuesta aprobada.

**Referencia del modelo de datos:** `docs/DATABASE_DESIGN.md` es el único documento de diseño de la base de datos. El esquema SQL se preparó y ejecutó antes del Sprint 1. El repositorio conserva `database/schema/SAPO_SCHEMA.sql` como esquema canónico, validado desde una base vacía con PostgreSQL 18.7 y con su batería automatizada. No se ha aplicado a la instancia local `sapo_db`; la recuperación o reproducción de las semillas de organización y tipos de incidente sigue pendiente.
