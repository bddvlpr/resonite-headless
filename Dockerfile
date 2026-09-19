FROM steamcmd/steamcmd:debian AS download-stage

RUN --mount=type=secret,id=steam_username,env=STEAM_USERNAME,required=true \
  --mount=type=secret,id=steam_password,env=STEAM_PASSWORD,required=true \
  --mount=type=secret,id=steam_branch_password,env=STEAM_BRANCH_PASSWORD,required=true \
  steamcmd \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /opt/resonite \
    +login "$STEAM_USERNAME" "$STEAM_PASSWORD" \
    +app_license_request 2519830 \
    +app_update 2519830 \
    -beta headless \
    -betapassword "$STEAM_BRANCH_PASSWORD" \
    +quit

FROM debian:13-slim AS runtime-stage

COPY --from=download-stage /opt/resonite/ /opt/resonite/
WORKDIR /opt/resonite/Headless

RUN apt update && \
  apt install -y curl && \
  curl https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm -rf packages-microsoft-prod.deb

RUN apt update && apt install -y libfreetype6 dotnet-runtime-10.0

RUN mkdir -p Libraries rml_mods rml_libs rml_config

RUN curl -SsL "https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony.dll" \
  -o "rml_libs/0Harmony.dll"
RUN curl -SsL "https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll" \
  -o "Libraries/ResoniteModLoader.dll"
RUN curl -SsL "https://codeberg.org/Raidriar/StresslessHeadless/releases/download/latest/StresslessHeadless.dll" \
  -o "rml_mods/StresslessHeadless.dll"
RUN curl -SsL "https://github.com/bddvlpr/ResoniteAgones/releases/latest/download/ResoniteAgones.Merged.dll" \
  -o "rml_mods/ResoniteAgones.Merged.dll"

ENTRYPOINT ["dotnet", "Resonite.dll", "-LoadAssembly", "Libraries/ResoniteModLoader.dll", "-HeadlessConfig", "/config.json"]
