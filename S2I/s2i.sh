yum install centos-release-scl-rh
yum --enablerepo=centos-sclo-rh-testing install source-to-image

docker pull registry.centos.org/dotnet/dotnet-21-centos7:latest


NuGet.Config

<configuration>
    <packageSources>
	<add key="repo" value="http://192.168.168.34/repository/nuget-hosted/" />
    </packageSources>
</configuration>



s2i build https://github.com/afshinpaydar/test.git registry.centos.org/dotnet/dotnet-21-centos7:latest afshin  -e DOTNET_STARTUP_PROJECT=SadTahli.WebApi/src/SadTahli.WebApi.csproj -e DOTNET_PUBLISH=/opt/app-root/app/  -e DOTNET_ASSEMBLY_NAME=Soshyant.Repo.SadTahli.WebApi -p always




oc new-app registry.centos.org/dotnet/dotnet-21-centos7:latest~https://github.com/afshinpaydar/test.git  -e DOTNET_STARTUP_PROJECT=SadTahli.WebApi/src/SadTahli.WebApi.csproj -e DOTNET_PUBLISH=/opt/app-root/app/  -e DOTNET_ASSEMBLY_NAME=Soshyant.Repo.SadTahli.WebApi