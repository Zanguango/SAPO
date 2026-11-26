# S.A.P.O. — Sistema Avanzado Policial Operativo

Prototipo académico de la asignatura **Proyecto de Ingeniería de Software (47GIIN), VIU**.

S.A.P.O. modela un escenario simulado de registro y consulta de incidencias asociadas a personas ficticias. Utiliza exclusivamente datos ficticios y no se conecta con sistemas policiales, judiciales ni administrativos reales. No es un producto de producción.

## Documentación y seguimiento

- [Product Backlog](docs/PRODUCT_BACKLOG.md)
- [Planificación Sprint 1](docs/SPRINT_1_PLAN.md)
- [Arquitectura de la solución](docs/ARCHITECTURE.md)
- [Estructura del proyecto](docs/PROJECT_STRUCTURE.md)
- [Entorno de desarrollo](docs/ENVIRONMENT.md)
- [Estrategia de datos iniciales ficticios](database/seeds/README.md)
- [Registro de trabajo del Sprint 1](docs/SPRINT_1_WORKLOG.md)
- [Diseño de la base de datos — referencia documental única](docs/DATABASE_DESIGN.md)
- [Checklist de seguridad y privacidad](docs/SECURITY_CHECKLIST.md)
- [Tablero GitHub Projects](https://github.com/users/Zanguango/projects/1)

## Alcance del incremento práctico

El incremento académico se limita a un circuito operativo: registrar y consultar incidencias asociadas a personas ficticias. Incluye las operaciones necesarias sobre personas e incidencias, asociación entre ambas, persistencia, validaciones y autenticación con permisos básicos. Los demás módulos se conservan como visión futura y no se comprometen para esta entrega.

## Tecnologías previstas

- Backend: JavaScript, Node.js y Express (API REST).
- Frontend: HTML, CSS y JavaScript.
- Base de datos: PostgreSQL.
- Arquitectura: cliente-servidor por capas.

## Estructura inicial

- `backend/src`: configuración, controladores, middleware, repositorios, rutas y servicios de la futura API.
- `frontend`: recursos CSS y JavaScript de la interfaz web.
- `database/schema`: ubicación reservada para el esquema SQL; el archivo de referencia aún no está versionado en GitHub.
- `database/seeds`: estrategia documentada; los scripts de carga todavía no están implementados.
- `tests`: pruebas unitarias y de integración.
- `docs`: backlog, planificación y documentación técnica.

La estructura es preparatoria: las carpetas no implican que las capas o funcionalidades estén implementadas.

## Estado (26/11/2026)

Las historias SAPO-001, SAPO-003, SAPO-028 y SAPO-030 del Sprint 1 aparecen cerradas como `Done` en GitHub Projects. La planificación del Sprint 1 (19–30/11/2026) fue aprobada por el profesor el 26/11/2026; el cierre formal de la iteración está previsto para el 30/11/2026.

La estructura inicial y la documentación de arquitectura, modelo de datos, entorno y seguridad están versionadas. El backend, la interfaz y la conexión Node.js/Express–PostgreSQL todavía no están implementados.

**Referencia del modelo de datos:** `docs/DATABASE_DESIGN.md` es el único documento de diseño de la base de datos. El esquema SQL se preparó y ejecutó antes del Sprint 1, pero el archivo SQL de referencia todavía no está incorporado al repositorio: `database/schema/` contiene únicamente `.gitkeep`. Por tanto, el repositorio aún no permite reconstruir la base de datos desde cero.
