{ ... }: {
  fileSystems."/mnt/nas" = {
    device = "nas:/volume1/homes";
    fsType = "nfs";
  };
}
