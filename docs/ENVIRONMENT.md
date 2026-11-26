# Entorno de desarrollo — S.A.P.O.

## 1. Inventario del entorno (comprobación del 26/11/2026)

| Componente | Tecnología | Estado comprobado |
|---|---|---|
| Sistema de trabajo | Windows 11 | Entorno local utilizado para el proyecto. |
| Base de datos | PostgreSQL 18.7 | Versión confirmada por la consulta SELECT version() ejecutada desde pgAdmin 4. |
| Administración de BD | pgAdmin 4 | Versión 9.19 confirmada en Help → About; conexión activa a sapo_db. |
| Base local | sapo_db, esquema public | Conexión confirmada; 24 tablas, 31 claves foráneas y los recuentos de datos de referencia indicados en el apartado 3. |
| Backend | JavaScript, Node.js y Express | Tecnología elegida. La API todavía no está implementada. En CMD, node y npm no se reconocieron como comandos el 26/11; instalación o PATH pendiente. |
| Frontend | HTML, CSS y JavaScript | Tecnología prevista; interfaz aún no implementada. |
| Control de versiones | Git y GitHub | Repositorio público disponible en GitHub. En CMD, git no se reconoció como comando el 26/11; instalación o PATH pendiente. |
| Seguimiento | GitHub Projects | Tablero del proyecto y Sprint 1 configurados. |

En una primera comprobación de CMD, node, npm y git se ejecutaron por separado y devolvieron el mensaje «no se reconoce como un comando interno o externo». En una segunda comprobación también ejecuté psql --version y obtuve el mismo resultado. Esto no demuestra por sí solo que no estén instalados: puede faltar su incorporación al PATH. En una comprobación posterior del 26/11/2026 ejecuté psql --version por separado y CMD indicó que no se reconoce como comando. Esto apunta a que las herramientas de línea de comandos de PostgreSQL no están instaladas o no están añadidas al PATH; no significa que el servidor PostgreSQL no funcione, ya que la conexión desde pgAdmin está confirmada. La versión de pgAdmin 4 es 9.19, confirmada en Help → About.

## 2. Requisitos previos para el desarrollo

Para desarrollar y ejecutar el prototipo necesitaré:
- PostgreSQL y la base sapo_db.
- pgAdmin o un cliente PostgreSQL equivalente.
- Node.js y npm para instalar dependencias y ejecutar la futura API.
- Git para trabajar con el repositorio.
- Un navegador web moderno para probar la interfaz.

Antes de iniciar el backend instalaré o configuraré las herramientas necesarias y comprobaré cada comando por separado en CMD o PowerShell. En las comprobaciones actuales, node, npm, git y psql no están disponibles como comandos:

```powershell
node --version
npm --version
git --version
psql --version
```

Para confirmar los detalles de PostgreSQL desde la propia base:

```sql
SELECT version();
SELECT current_database(), current_schema();
```

## 3. Comprobación local de la base de datos — 26/11/2026

He ejecutado una consulta de verificación en pgAdmin 4, conectado a sapo_db. El resultado mostrado es:

| Indicador | Resultado |
|---|---:|
| Base de datos | sapo_db |
| Esquema | public |
| Versión | PostgreSQL 18.7, 64 bits |
| Tablas | 24 |
| Claves foráneas | 31 |
| Organizaciones | 1 |
| Tipos de incidente | 7 |
| Estados de incidente | 4 |
| Transiciones de estado | 5 |
| Personas | 0 |
| Incidentes | 0 |

Los recuentos de tablas y claves foráneas son una comprobación de la instancia en ejecución; no equivalen a una inspección individual de cada columna, índice, restricción, función y trigger.

La organización y los siete tipos de incidente ya existen en mi base local. El SQL de referencia incluye la creación y los datos iniciales de PERFIL, ESTADO_INCIDENTE y TRANSICION_ESTADO_INCIDENTE, pero no incorpora registros iniciales de ORGANIZACION ni TIPO_INCIDENTE. La procedencia de los registros locales de estas dos tablas se está investigando en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51).

## 4. Disponibilidad de herramientas de línea de comandos — 26/11/2026

He consultado Help → About en pgAdmin y he confirmado la versión 9.19 (Desktop), con Python 3.13.14 y Electron 45.2.3. Esta captura completa el inventario de pgAdmin.

He comprobado que los comandos node, npm y git no se reconocen en CMD. En una comprobación posterior, psql tampoco se reconoce cuando se ejecuta por separado. La primera línea de la última captura concatenaba varios comandos en una sola instrucción y no permite verificar npm ni Git; para esos dos comandos se conserva como evidencia la captura anterior, donde se ejecutaron individualmente. Antes del Sprint 2 tendré que instalar Node.js y Git o corregir el PATH y, si necesito usar psql, instalar las herramientas de cliente o añadir su carpeta bin al PATH.

## 5. Trabajo previo al Sprint 1

Antes de iniciar el Sprint 1 ya había preparado el esquema SQL de S.A.P.O., creado la base local sapo_db y ejecutado el script de definición de la base de datos. Este trabajo es la base de partida del proyecto y no lo contabilizo como esfuerzo realizado dentro del Sprint 1. La fecha exacta de esos trabajos previos no se está reconstruyendo retrospectivamente.

Durante el Sprint 1 estoy documentando el modelo del circuito práctico, verificando la instancia local y definiendo cómo preparar datos ficticios relacionados.

## 6. Variables de entorno del futuro backend

He preparado backend/.env.example como plantilla de nombres de configuración. Cuando implemente la API:
1. Copiaré el ejemplo a un archivo local .env.
2. Completaré los valores únicamente en ese archivo local.
3. No subiré .env, contraseñas, tokens ni secretos a GitHub.

Variables previstas:
- PORT: puerto HTTP de la API.
- DB_HOST: servidor PostgreSQL.
- DB_PORT: puerto de PostgreSQL.
- DB_NAME: nombre de base de datos; inicialmente sapo_db.
- DB_USER: usuario de conexión con privilegios mínimos necesarios.
- DB_PASSWORD: contraseña local, que nunca debe versionarse.

El archivo de ejemplo contiene valores de muestra, no credenciales reales. Todavía no existe un backend que consuma esta configuración.

## 7. Datos iniciales ficticios

Mantendré los scripts de datos iniciales separados del esquema. Las cargas respetarán las dependencias entre entidades y utilizarán exclusivamente datos ficticios. La organización y los siete tipos de incidente ya están en mi base local, junto con los catálogos de estados y transiciones. Antes de recrear el entorno, documentaré y versionaré una carga reproducible de esos datos de referencia, evitando duplicar los que ya existen.

La secuencia de preparación está documentada en database/seeds/README.md.

## 8. Arranque de la aplicación

Todavía no puedo proporcionar comandos de ejecución del producto: el backend y el frontend no están implementados. Cuando cree el proyecto Node.js/Express y la interfaz, completaré este apartado con instalación de dependencias, configuración local y comandos de arranque verificados.
