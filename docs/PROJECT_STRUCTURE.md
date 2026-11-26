# Estructura inicial del proyecto

La estructura organiza el código y la documentación de S.A.P.O. de acuerdo con la arquitectura cliente-servidor por capas. Los directorios se crean como base de trabajo; su existencia no implica que las funcionalidades estén implementadas.

```text
SAPO/
├── README.md
├── .gitignore
├── backend/
│   ├── .env.example
│   └── src/
│       ├── config/.gitkeep
│       ├── controllers/.gitkeep
│       ├── middleware/.gitkeep
│       ├── repositories/.gitkeep
│       ├── routes/.gitkeep
│       └── services/.gitkeep
├── database/
│   ├── schema/.gitkeep
│   └── seeds/
│       ├── .gitkeep
│       └── README.md
├── docs/
│   ├── PROJECT_BASELINE.md
│   ├── PRODUCT_BACKLOG.md
│   ├── SPRINT_1_PLAN.md
│   ├── ARCHITECTURE.md
│   ├── PROJECT_STRUCTURE.md
│   ├── DATABASE_DESIGN.md
│   ├── ENVIRONMENT.md
│   ├── SPRINT_1_WORKLOG.md
│   └── SECURITY_CHECKLIST.md
├── frontend/
│   ├── css/.gitkeep
│   └── js/.gitkeep
└── tests/
    ├── integration/.gitkeep
    └── unit/.gitkeep
```

## Directorios

| Ruta | Responsabilidad prevista |
|---|---|
| `docs/` | Línea base de decisiones, Product Backlog, planificación y documentación técnica y metodológica. |
| `backend/src/config/` | Configuración de la aplicación y acceso a parámetros de entorno. |
| `backend/src/controllers/` | Adaptación de peticiones HTTP a casos de uso. |
| `backend/src/middleware/` | Autenticación, autorización y tratamiento transversal de peticiones. |
| `backend/src/repositories/` | Acceso a datos y consultas PostgreSQL. |
| `backend/src/routes/` | Definición y agrupación de endpoints de la API REST. |
| `backend/src/services/` | Reglas de negocio y coordinación de operaciones. |
| `frontend/css/` | Hojas de estilo de la interfaz web. |
| `frontend/js/` | Lógica de interacción y consumo de la API desde el navegador. |
| `database/schema/` | Contiene el esquema canónico `SAPO_SCHEMA.sql`, validado desde una base vacía con PostgreSQL 18.7. La instancia `sapo_db` permanece sin modificar. |
| `database/seeds/` | Estrategia documentada; la carga reproducible de organización y tipos de incidente sigue pendiente (#51). |
| `database/diagnostics/` | Consultas de diagnóstico de solo lectura para comparar la instancia local con el esquema canónico para valorar una migración segura (#56). |
| `tests/unit/` | Pruebas unitarias. |
| `tests/integration/` | Pruebas de integración entre componentes y persistencia. |

## Convenciones iniciales

- Mantener la lógica de negocio en servicios, no en controladores HTTP.
- Mantener el acceso SQL encapsulado en repositorios.
- No incluir archivos `.env`, contraseñas, tokens ni datos personales reales.
- Mantener versionado el esquema canónico validado; cualquier sincronización con `sapo_db` requiere una migración separada, revisada y documentada.
- Versionar por separado los scripts idempotentes de carga de datos ficticios cuando se complete la tarea #51.
- Mantener separados el esquema de base de datos y los scripts de carga de datos.
- Añadir archivos de código cuando se implemente cada componente, no crear código vacío para simular funcionalidad.
